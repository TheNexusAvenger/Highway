--[[
TheNexusAvenger

Tests the ScriptHashCollection.
--]]
--!strict
--$NexusUnitTestExtensions

local ScriptHashCollection = require(game:GetService("ReplicatedStorage").HighwayPlugin.Collection.ScriptHashCollection)

return function()
    describe("A ScriptHashCollection instance", function()
        it("should add containers.", function()
            local Collection = ScriptHashCollection.new()
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local ParentScript1 = Instance.new("ModuleScript")
            ParentScript1.Name = "TestScript1"
            ParentScript1.Source = "Source1"
            ParentScript1.Parent = Folder2
            local ChildScript = Instance.new("ModuleScript")
            ChildScript.Name = "TestScript2"
            ChildScript.Source = "Source2"
            ChildScript.Parent = ParentScript1

            Collection:AddScripts(Folder1)
            expect(Collection:ToJson()).to.deepEqual({
                hashMethod = "SHA256",
                hashes = {
                    ["Folder1/Folder2/TestScript1/init.lua"] = "0f91b5c398faf5a579ac42ec5096962c9d320438816d1c2d5df8f2e737e96dc2",
                    ["Folder1/Folder2/TestScript1/TestScript2.lua"] = "11319e8661d9663c48c20f45450f282f2dff04d094a6ab34fe7c5dbdff9d6cee",
                },
            })
        end)
    end)
end