--[[
TheNexusAvenger

Action for pulling changed files into Roblox Studio.
--]]
--!strict

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
function PullAction:ApplyDifferences(): ()
    --TODO: Implement
end



return (PullAction :: any) :: PullAction