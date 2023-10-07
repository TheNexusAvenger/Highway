--[[
TheNexusAvenger

Types used by the plugin.
--]]

local NexusPluginComponents = require(script.Parent:WaitForChild("NexusPluginComponents"))

--Classes
export type ScriptHashCollection = {
    new: () -> (ScriptHashCollection),
    FromManifest: (Manifest: ProjectManifest) -> (ScriptHashCollection),
    Hashes: {[Instance]: string},
    AddScript: (self: ScriptHashCollection, Script: LuaSourceContainer) -> (),
    AddScripts: (self: ScriptHashCollection, Container: Instance) -> (),
    ToJson: (self: ScriptHashCollection) -> (ScriptHashCollectionJson),
}

export type BasePromptFrame = {
    ContentsFrame: NexusPluginComponents.PluginInstance,
    BottomBar: NexusPluginComponents.PluginInstance,
    StatusText: NexusPluginComponents.PluginInstance,
    ConfirmButton: NexusPluginComponents.PluginInstance,
    CancelButton: NexusPluginComponents.PluginInstance,

    new: () -> (BasePromptFrame),
    Extend: (self: BasePromptFrame) -> (BasePromptFrame),
    Load: (self: BasePromptFrame) -> (),
} & NexusPluginComponents.PluginInstance & Frame

--Requests
export type ScriptHashCollectionJson = {
    hashMethod: "SHA256",
    hashes: {[string]: string},
}

--Respones
export type ProjectManifest = {
    Name: string?,
    PushPlaceId: number?,
    SyncPlaceId: number?,
    Git: {
        CheckoutBranch: string,
        PushBranch: string,
        CommitMessage: string?,
    },
    Paths: {[string]: string},
}

export type FileHashes = {
    HashMethod: string,
    Hashes: {[string]: string},
}

return {}