--[[
TheNexusAvenger

Action for pushing files out of Roblox Studio.
--]]
--!strict

local CommonAction = require(script.Parent:WaitForChild("CommonAction"))
local ScriptHashCollection = require(script.Parent.Parent:WaitForChild("Collection"):WaitForChild("ScriptHashCollection"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local PushAction = {}
PushAction.__index = PushAction
setmetatable(PushAction, CommonAction)

export type PushAction = {
    Manifest: Types.ProjectManifest,
    ScriptHashCollection: Types.ScriptHashCollection,
    new: () -> (PushAction),
    AddScripts: (self: PushAction) -> (),
    PushScripts: (self: PushAction, ProgressCallback: (string, number) -> ()) -> (),
} & CommonAction.CommonAction



--[[
Creates a PushAction instance.
--]]
function PushAction.new(): PushAction
    local self = CommonAction.new() :: any
    setmetatable(self, PushAction)
    self.Manifest = self:GetProjectManifest()
    self.ScriptHashCollection = ScriptHashCollection.new()
    return self :: PushAction
end

--[[
Adds all the scripts to the hash collection.
--]]
function PushAction:AddScripts(): ()
    for Path, _ in self.Manifest.Paths do
        local NewPath, _ = string.gsub(Path, "%.", "/")
        for _, Container in self.ScriptHashCollection.FindInstances(NewPath) do
            self.ScriptHashCollection:AddScripts(Container)
        end
    end
end

--[[
Pushes the scripts to the remote.
--]]
function PushAction:PushScripts(ProgressCallback: (string, number) -> ()): ()
    --Get the scripts to push.
    local ScriptsToPush = {}
    for Script, _ in self.ScriptHashCollection.Hashes do
        table.insert(ScriptsToPush, Script)
    end

    --Create the session.
    local PushSessionId = self:PerformAndParseRequest("POST", "/push/session/start", self.ScriptHashCollection:ToJson()).Body.session
    
    --Push the scripts.
    for i, Script in ScriptsToPush do
        ProgressCallback("Preparing scripts ("..tostring(i).."/"..tostring(#ScriptsToPush)..")", i / #ScriptsToPush)
        self:PerformAndParseRequest("POST", "/push/session/add", {
            session = PushSessionId,
            scriptPath = ScriptHashCollection.GetScriptPath(Script),
            contents = Script.Source,
        } :: any)
    end

    --Complete the session.
    ProgressCallback("Pushing changes", 1)
    self:PerformAndParseRequest("POST", "/push/session/complete", {
        session = PushSessionId,
    } :: any)
end



return (PushAction :: any) :: PushAction