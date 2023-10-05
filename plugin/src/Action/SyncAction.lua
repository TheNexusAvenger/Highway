--[[
TheNexusAvenger

Action for syncing changed files into Roblox Studio for rapid testing.
--]]
--!strict

local SYNC_UPDATE_DELAY = 0.1

local CommonAction = require(script.Parent:WaitForChild("CommonAction"))
local PathUtil = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("PathUtil"))
local ScriptUtil = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("ScriptUtil"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local SyncAction = {}
SyncAction.__index = SyncAction
setmetatable(SyncAction, CommonAction)

export type SyncAction = {
    Active: boolean,
    Manifest: Types.ProjectManifest,
    new: () -> (SyncAction),
    Resync: (self: SyncAction) -> (),
    Start: (self: SyncAction) -> (),
    Stop: (self: SyncAction) -> (),
} & CommonAction.CommonAction



--[[
Creates a SyncAction instance.
--]]
function SyncAction.new(): SyncAction
    local self = CommonAction.new() :: any
    setmetatable(self, SyncAction)
    self.Manifest = self:GetProjectManifest()
    self.Active = false
    return self :: SyncAction
end

--[[
Resyncs all of the stored scripts.
--]]
function SyncAction:Resync(): ()
    --Get the hashes.
    local SystemHashes = (self:GetFileHashes() :: Types.FileHashes).Hashes

    --Clear the deleted scripts.
    for ScriptBasePath, _ in self.Manifest.Paths do
        local Container = PathUtil.FindInstances(ScriptBasePath)[1];
        if Container then
            for _, Child in Container:GetDescendants() do
                if not Child:IsA("LuaSourceContainer") then continue end
                local ChildPath = PathUtil.GetScriptPath(Child)
                if SystemHashes[ChildPath] then continue end
                ScriptUtil.Delete(ChildPath)
            end
        end
    end

    --Update the scripts.
    for ScriptPath, _ in SystemHashes do
        ScriptUtil.CreateOrUpdate(ScriptPath, self:GetSource(ScriptPath))
    end
end

--[[
Starts constant syncing.
--]]
function SyncAction:Start(): ()
    if self.Active then return end
    self.Active = true

    --Preform the initial resync.
    self:Resync()

    --Run the sync.
    task.spawn(function()
        while self.Active do
            --Wait to update.
            task.wait(SYNC_UPDATE_DELAY)
            if not self.Active then break end

            --Get and apply the changes.
            local Changes = self:PerformAndParseRequest("GET", "/file/list/hashes/changes").Body
            if Changes.resync then
                self:Resync()
            else
                for ScriptPath, ScriptHash in Changes.hashes.hashes do
                    if ScriptHash == "DELETED" then
                        ScriptUtil.Delete(ScriptPath)
                    else
                        ScriptUtil.CreateOrUpdate(ScriptPath, self:GetSource(ScriptPath))
                    end
                end
            end
        end
    end)
end

--[[
Stops constant syncing.
--]]
function SyncAction:Stop(): ()
    self.Active = false
end



return (SyncAction :: any) :: SyncAction