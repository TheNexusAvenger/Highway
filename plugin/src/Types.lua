--[[
TheNexusAvenger

Types used by the plugin.
--]]

--Classes
export type ScriptHashCollection = {
    GetScriptPath: (Script: Instance) -> (string),
    FindInstances: (Path: string, Parent: Instance?) -> ({Instance}),
    FindScript: (Path: string, Parent: Instance?) -> (LuaSourceContainer?),

    new: () -> (ScriptHashCollection),
    Hashes: {[Instance]: string},
    AddScript: (self: ScriptHashCollection, Script: Script | LocalScript | ModuleScript) -> (),
    AddScripts: (self: ScriptHashCollection, Container: Instance) -> (),
}

--Requests
export type ScriptHashCollectionJson = {
    hashMethod: "SHA256",
    hashes: {[string]: string},
}

return {}