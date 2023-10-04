--[[
TheNexusAvenger

Action for pulling changed files into Roblox Studio.
--]]
--!strict

local ScriptEditorService = game:GetService("ScriptEditorService")

local CommonAction = require(script.Parent:WaitForChild("CommonAction"))
local ScriptHashCollection = require(script.Parent.Parent:WaitForChild("Collection"):WaitForChild("ScriptHashCollection"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local PullAction = {}
PullAction.__index = PullAction
setmetatable(PullAction, CommonAction)

export type HashDifference = {
    Old: string?,
    New: string?,
}

export type PullAction = {
    HashDifferences: {[string]: {HashDifference}},
    Manifest: Types.ProjectManifest,
    ScriptHashCollection: Types.ScriptHashCollection,
    new: () -> (PullAction),
} & CommonAction.CommonAction



--[[
Creates a PullAction instance.
--]]
function PullAction.new(): PullAction
    local self = CommonAction.new() :: any
    setmetatable(self, PullAction)
    self.Manifest = self:GetProjectManifest()
    self.HashDifferences = {}
    return self :: PullAction
end

--[[
Calculate the hash differences.
--]]
function PullAction:CalculateHashDifferences(): ()
    --Add the new/changed files.
    local SystemHashes = (self:GetFileHashes() :: Types.FileHashes).Hashes
    local StudioHashes = {}
    for Script, Hash in ScriptHashCollection.FromManifest(self:GetProjectManifest()).Hashes do
        StudioHashes[ScriptHashCollection.GetScriptPath(Script)] = Hash
    end
    for ScriptPath, SystemHash in SystemHashes do
        local StudioHash = StudioHashes[ScriptPath]
        if SystemHash == StudioHash then continue end
        if not string.find(string.lower(ScriptPath), "%.lua$") then continue end
        self.HashDifferences[ScriptPath] = {
            Old = StudioHash,
            New = SystemHash,
        } :: HashDifference
    end
    
    --Add the deleted files.
    for ScriptPath, StudioHash in StudioHashes do
        if SystemHashes[ScriptPath] then continue end
        self.HashDifferences[ScriptPath] = {
            Old = StudioHash,
            New = nil,
        } :: HashDifference
    end
end

--[[
Applies the differences.
--]]
function PullAction:ApplyDifferences(Parent: Instance?): ()
    Parent = Parent or game

    --Fetch the script sources.
    local NewSources = {}
    for ScriptPath, HashDifference in self.HashDifferences do
        if not HashDifference.New then continue end
        NewSources[ScriptPath] = self:PerformAndParseRequest("GET", "/file/read?path="..ScriptPath).Body.contents
    end
    
    --Apply the differences.
    for ScriptPath, HashDifference in self.HashDifferences do
        if HashDifference.New and HashDifference.Old then
            --Update the script.
            local ExistingScript = ScriptHashCollection.FindScript(ScriptPath)
            if ExistingScript then
                ScriptEditorService:UpdateSourceAsync(ScriptHashCollection.FindScript(ScriptPath), function()
                    return NewSources[ScriptPath]
                end)
            end
        elseif HashDifference.New then
            --Clear init from the path.
            local ScriptSource = NewSources[ScriptPath]
            ScriptPath = string.gsub(ScriptPath, "/init%.", ".")

            --Create the folders to the script.
            local SplitPath = string.split(ScriptPath, "/")
            local ScriptParent = Parent :: Instance
            for i = 1, #SplitPath - 1 do
                local Child = ScriptParent:FindFirstChild(SplitPath[i]) :: Instance
                if not Child then
                    local NewChild = Instance.new("Folder")
                    NewChild.Name = SplitPath[i]
                    NewChild.Parent = ScriptParent
                    Child = NewChild
                end
                ScriptParent = Child
            end

            --Determine the type.
            local Extension, ScriptType = nil, nil
            local ScriptName = SplitPath[#SplitPath]
            if string.find(string.lower(ScriptName), "%.server%.lua$") then
                Extension = ".server.lua"
                ScriptType = "Script"
            elseif string.find(string.lower(ScriptName), "%.client%.lua$") then
                Extension = ".client.lua"
                ScriptType = "LocalScript"
            elseif string.find(string.lower(ScriptName), "%.lua$") then
                Extension = ".lua"
                ScriptType = "ModuleScript"
            end
            if not ScriptType then continue end
            ScriptName = string.sub(ScriptName, 1, string.len(ScriptName) - string.len(Extension))

            --Determine if there is an existing folder to replace.
            --Folders may be created by the above step.
            local ExistingFolder = ScriptParent:FindFirstChild(ScriptName)
            if ExistingFolder and not ExistingFolder:IsA("Folder") then
                ExistingFolder = nil
            end

            --Create the script.
            local NewScript = Instance.new(ScriptType)
            NewScript.Name = ScriptName;
            (NewScript :: any).Source = ScriptSource
            NewScript.Parent = ScriptParent

            --Clear the existing folder.
            if ExistingFolder then
                for _, Child in ExistingFolder:GetChildren() do
                    Child.Parent = NewScript
                end
                ExistingFolder:Destroy()
            end
        else
            --Unparent children from the script and clear the script.
            local ExistingScript = ScriptHashCollection.FindScript(ScriptPath)
            if ExistingScript then
                if #ExistingScript:GetChildren() > 0 then
                    local NewFolder = Instance.new("Folder")
                    NewFolder.Name = ExistingScript.Name
                    NewFolder.Parent = ExistingScript.Parent

                    for _, Child in ExistingScript:GetChildren() do
                        Child.Parent = NewFolder
                    end
                end
                ExistingScript:Destroy()
            end
        end
    end
end



return (PullAction :: any) :: PullAction