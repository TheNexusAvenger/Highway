--[[
TheNexusAvenger

Stores the hashes of scripts.
--]]
--!strict

local SHA256 = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("SHA256"))

local ScriptHashCollection = {}
ScriptHashCollection.__index = ScriptHashCollection

export type ScriptHashCollection = {
    GetScriptPath: (Script: Instance) -> (string),
    FindInstances: (Path: string, Parent: Instance?) -> ({Instance}),
    FindScript: (Path: string, Parent: Instance?) -> (LuaSourceContainer?),

    new: () -> (ScriptHashCollection),
    Hashes: {[string]: string},
    AddScript: (self: ScriptHashCollection, Script: Script | LocalScript | ModuleScript) -> (),
    AddScripts: (self: ScriptHashCollection, Container: Instance) -> (),
}

--[[
Returns the path for a script.
--]]
function ScriptHashCollection.GetScriptPath(Script: Instance): string
    --Build the path.
    local Path = ""
    local CurrentInstance = Script
    while CurrentInstance and CurrentInstance ~= game do
        Path = CurrentInstance.Name..Path
        CurrentInstance = CurrentInstance.Parent :: Instance
        if CurrentInstance and CurrentInstance ~= game then
            Path = "/"..Path
        end
    end

    --Add init to the path if there is a child script.
    for _, Child in Script:GetDescendants() do
        if not Child:IsA("LuaSourceContainer") then continue end
        Path = Path.."/init"
        break
    end

    --Add the extension.
    if Script:IsA("LocalScript") then
        Path = Path..".client.lua"
    elseif Script:IsA("Script") then
        Path = Path..".server.lua"
    else
        Path = Path..".lua"
    end

    --Return the path.
    return Path
end

--[[
Finds all the instances for the given path.
--]]
function ScriptHashCollection.FindInstances(Path: string, Parent: Instance?): {Instance}
    Parent = Parent or game
    
    --Move down the path.
    local PathParts = string.split(Path, "/")
    for i = 1, #PathParts - 1 do
        if not Parent then return {} end
        Parent = Parent:FindFirstChild(PathParts[i])
    end
    if not Parent then return {} end

    --Add and return all the children that match the name.
    local InstanceName = PathParts[#PathParts]
    local Children = {}
    for _, Child in Parent:GetChildren() do
        if Child.Name ~= InstanceName then continue end
        table.insert(Children, Child)
    end
    return Children
end

--[[
Attempts to find a script given a path.
Returns nil if the instances does not exist or is not a script.
--]]
function ScriptHashCollection.FindScript(Path: string, Parent: Instance?): LuaSourceContainer?
    --Determine the type.
    local Extension, ScriptType = nil, nil
    if string.find(string.lower(Path), "%.server%.lua$") then
        Extension = ".server.lua"
        ScriptType = "Script"
    elseif string.find(string.lower(Path), "%.client%.lua$") then
        Extension = ".client.lua"
        ScriptType = "LocalScript"
    elseif string.find(string.lower(Path), "%.lua$") then
        Extension = ".lua"
        ScriptType = "ModuleScript"
    end
    if not ScriptType then return nil end

    --Convert the script path to an instance path.
    Path = string.sub(Path, 1, string.len(Path) - string.len(Extension))
    if string.find(Path, "/init$") then
        Path = string.sub(Path, 1, string.len(Path) - 5)
    end

    --Return the first instance that matches the type.
    for _, Child in ScriptHashCollection.FindInstances(Path, Parent) do
        if Child.ClassName ~= ScriptType then continue end
        return Child :: LuaSourceContainer
    end
    return nil
end

--[[
Creates a ScriptHashCollection instance.
--]]
function ScriptHashCollection.new(): ScriptHashCollection
    return (setmetatable({
        Hashes = {},
    }, ScriptHashCollection) :: any) :: ScriptHashCollection
end

--[[
Adds a script hash.
--]]
function ScriptHashCollection:AddScript(Script: Script | LocalScript | ModuleScript): ()
    self.Hashes[ScriptHashCollection.GetScriptPath(Script)] = SHA256(Script.Source)
end

--[[
Adds a container of scripts.
--]]
function ScriptHashCollection:AddScripts(Container: Instance): ()
    for _, Child in Container:GetDescendants() do
        if not Child:IsA("LuaSourceContainer") then continue end
        self:AddScript(Child :: any)
    end
end



return (ScriptHashCollection :: any) :: ScriptHashCollection