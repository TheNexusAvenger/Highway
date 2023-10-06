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
    IntegrityCheckHashes: {[string]: HashDifference},
    HashDifferences: {[string]: HashDifference},
    Manifest: Types.ProjectManifest,
    ScriptHashCollection: Types.ScriptHashCollection,
    new: () -> (PullAction),
    PerformIntegrityCheck: (self: PullAction) -> (),
    CalculateHashDifferences: (self: PullAction) -> (),
    ApplyDifferences: (self: PullAction, ProgressCallback: (string) -> (), Parent: Instance?) -> (),
} & CommonAction.CommonAction



--[[
Creates a PullAction instance.
--]]
function PullAction.new(): PullAction
    local self = CommonAction.new() :: any
    setmetatable(self, PullAction)
    self.Manifest = self:GetProjectManifest()
    self.IntegrityCheckHashes = {}
    self.HashDifferences = {}
    return self :: PullAction
end

--[[
Checks that the list of hashes stored on the server are the same.
--]]
function PullAction:PerformIntegrityCheck(): ()
    local SystemHashes = (self:GetFileHashes("/project/hashes") :: Types.FileHashes).Hashes
    local StudioHashes = {}
    for Script, Hash in ScriptHashCollection.FromManifest(self:GetProjectManifest()).Hashes do
        StudioHashes[PathUtil.GetScriptPath(Script)] = Hash
    end
    for ScriptPath, SystemHash in SystemHashes do
        local StudioHash = StudioHashes[ScriptPath]
        if StudioHash then
            self.IntegrityCheckHashes[ScriptPath] = {
                Old = SystemHash,
                New = StudioHash,
            } :: HashDifference
        else
            self.IntegrityCheckHashes[ScriptPath] = {
                Old = SystemHash,
                New = nil,
            } :: HashDifference
        end
    end
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
function PullAction:ApplyDifferences(ProgressCallback: (string) -> (), Parent: Instance?): ()
    Parent = Parent or game

    --Determine the total scripts.
    local TotalScriptsToPull, TotalScripts = 0, 0
    for ScriptPath, HashDifference in self.HashDifferences do
        TotalScripts += 1
        if not HashDifference.New then continue end
        TotalScriptsToPull += 1
    end

    --Fetch the script sources.
    local NewSources = {}
    local PulledScriptsCount = 0
    for ScriptPath, HashDifference in self.HashDifferences do
        ProgressCallback("Reading scripts... ("..tostring(PulledScriptsCount + 1).."/"..tostring(TotalScriptsToPull)..")")
        if not HashDifference.New then continue end
        NewSources[ScriptPath] = self:GetSource(ScriptPath)
        PulledScriptsCount += 1
    end
    
    --Apply the differences.
    local UpdatedScriptsCount = 0
    for ScriptPath, HashDifference in self.HashDifferences do
        ProgressCallback("Updating scripts... ("..tostring(UpdatedScriptsCount + 1).."/"..tostring(TotalScripts)..")")
        if HashDifference.New then
            ScriptUtil.CreateOrUpdate(ScriptPath, NewSources[ScriptPath], Parent)
        else
            ScriptUtil.Delete(ScriptPath, Parent)
        end
        UpdatedScriptsCount += 1
    end
end



return (PullAction :: any) :: PullAction