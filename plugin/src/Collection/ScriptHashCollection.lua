--[[
TheNexusAvenger

Stores the hashes of scripts.
--]]
--!strict

local PathUtil = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("PathUtil"))
local SHA256 = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("SHA256"))
local Types = require(script.Parent.Parent:WaitForChild("Types"))

local ScriptHashCollection = {}
ScriptHashCollection.__index = ScriptHashCollection



--[[
Creates a ScriptHashCollection instance.
--]]
function ScriptHashCollection.new(): Types.ScriptHashCollection
    return (setmetatable({
        Hashes = {},
    }, ScriptHashCollection) :: any) :: Types.ScriptHashCollection
end

--[[
Creates a ScriptHashCollection instance for a manifest..
--]]
function ScriptHashCollection.FromManifest(Manifest: Types.ProjectManifest): Types.ScriptHashCollection
    local Collection = ScriptHashCollection.new()
    for Path, _ in Manifest.Paths do
        for _, Container in PathUtil.FindInstances(Path) do
            Collection:AddScripts(Container)
        end
    end
    return Collection
end

--[[
Adds a script hash.
--]]
function ScriptHashCollection:AddScript(Script: Script | LocalScript | ModuleScript): ()
    local Source, _ = string.gsub(Script.Source, "\r", "")
    self.Hashes[Script] = SHA256(Source)
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

--[[
Creates a JSON body object for HTTP requests.
--]]
function ScriptHashCollection:ToJson(): Types.ScriptHashCollectionJson
    --Store the hashes.
    local Hashes = {}
    for Script, Hash in self.Hashes do
        Hashes[PathUtil.GetScriptPath(Script)] = Hash
    end

    --Return the object.
    return {
        hashMethod = "SHA256",
        hashes = Hashes,
    }
end



return (ScriptHashCollection :: any) :: Types.ScriptHashCollection