--[[
TheNexusAvenger

Action for pulling changed files into Roblox Studio.
--]]
--!strict

local CommonAction = require(script.Parent:WaitForChild("CommonAction"))
local ScriptHashCollection = require(script.Parent.Parent:WaitForChild("Collection"):WaitForChild("ScriptHashCollection"))
local PathUtil = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("PathUtil"))
local ScriptUtil = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("ScriptUtil"))
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
        StudioHashes[PathUtil.GetScriptPath(Script)] = Hash
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
        if HashDifference.New then
            ScriptUtil.CreateOrUpdate(ScriptPath, NewSources[ScriptPath], Parent)
        else
            ScriptUtil.Delete(ScriptPath, Parent)
        end
    end
end



return (PullAction :: any) :: PullAction