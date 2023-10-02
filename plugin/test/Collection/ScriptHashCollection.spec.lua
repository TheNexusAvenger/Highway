--[[
TheNexusAvenger

Tests the ScriptHashCollection.
--]]
--!strict
--$NexusUnitTestExtensions

local ScriptHashCollection = require(game:GetService("ReplicatedStorage").HighwayPlugin.Collection.ScriptHashCollection)

return function()
    describe("The GetScriptPath helper method", function()
        local InstanceToClear = nil
        afterEach(function()
            if not InstanceToClear then return end
            InstanceToClear:Destroy()
        end)

        it("should return a path for an unparented script.", function()
            local Script = Instance.new("ModuleScript")
            Script.Name = "TestScript"

            expect(ScriptHashCollection.GetScriptPath(Script)).to.equal("TestScript.lua")
        end)

        it("should return a path for a parented script.", function()
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local Script = Instance.new("ModuleScript")
            Script.Name = "TestScript"
            Script.Parent = Folder2

            expect(ScriptHashCollection.GetScriptPath(Script)).to.equal("Folder1/Folder2/TestScript.lua")
        end)

        it("should return a path for a parented script with child scripts.", function()
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local Script = Instance.new("ModuleScript")
            Script.Name = "TestScript"
            Script.Parent = Folder2
            local ChildScript = Instance.new("ModuleScript")
            ChildScript.Name = "ChildScript"
            ChildScript.Parent = Script

            expect(ScriptHashCollection.GetScriptPath(Script)).to.equal("Folder1/Folder2/TestScript/init.lua")
            expect(ScriptHashCollection.GetScriptPath(ChildScript)).to.equal("Folder1/Folder2/TestScript/ChildScript.lua")
        end)

        it("should not add game to the paths.", function()
            local Folder = Instance.new("Folder")
            Folder.Name = "Folder1"
            Folder.Parent = game:GetService("ReplicatedStorage")
            InstanceToClear = Folder
            local Script = Instance.new("ModuleScript")
            Script.Name = "TestScript"
            Script.Parent = Folder

            expect(ScriptHashCollection.GetScriptPath(Script)).to.equal("ReplicatedStorage/Folder1/TestScript.lua")
        end)

        it("should add server script extensions.", function()
            local Script = Instance.new("Script")
            Script.Name = "TestScript"

            expect(ScriptHashCollection.GetScriptPath(Script)).to.equal("TestScript.server.lua")
        end)

        it("should add local script extensions.", function()
            local Script = Instance.new("LocalScript")
            Script.Name = "TestScript"

            expect(ScriptHashCollection.GetScriptPath(Script)).to.equal("TestScript.client.lua")
        end)
    end)

    describe("The FindInstances and FindScript helper methods", function()
        local Parent = nil
        local Script1, Script2, Script3, Script4 = nil, nil, nil, nil
        beforeEach(function()
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Parent = Folder1
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local ParentScript1 = Instance.new("ModuleScript")
            ParentScript1.Name = "TestScript"
            ParentScript1.Parent = Folder2
            Script1 = ParentScript1
            local ChildScript1 = Instance.new("ModuleScript")
            ChildScript1.Name = "TestScript"
            ChildScript1.Parent = ParentScript1
            Script2 = ChildScript1
            local ChildScript2 = Instance.new("Script")
            ChildScript2.Name = "TestScript"
            ChildScript2.Parent = ParentScript1
            Script3 = ChildScript2
            local ChildScript3 = Instance.new("LocalScript")
            ChildScript3.Name = "TestScript"
            ChildScript3.Parent = ParentScript1
            Script4 = ChildScript3
        end)

        it("should return an empty list for unknown paths.", function()
            expect(#ScriptHashCollection.FindInstances("Unknown", Parent)).to.equal(0)
            expect(#ScriptHashCollection.FindInstances("Folder2/Unknown2/Unknown2", Parent)).to.equal(0)
        end)

        it("should return instances with correct paths.", function()
            expect(ScriptHashCollection.FindInstances("Folder2/TestScript", Parent)).to.deepEqual({Script1})
            expect(ScriptHashCollection.FindInstances("Folder2/TestScript/TestScript", Parent)).to.deepEqual({Script2, Script3, Script4} :: {Instance})
        end)

        it("should return nil for non-script extensions.", function()
            expect(ScriptHashCollection.FindScript("Folder2/TestScript", Parent)).to.equal(nil)
            expect(ScriptHashCollection.FindScript("Folder2/TestScript.cs", Parent)).to.equal(nil)
        end)

        it("should return nil for unknown script paths.", function()
            expect(ScriptHashCollection.FindScript("Unknown.lua", Parent)).to.equal(nil)
            expect(ScriptHashCollection.FindScript("Folder2/Unknown2/Unknown2.lua", Parent)).to.equal(nil)
        end)

        it("should return scripts matches the extension.", function()
            expect(ScriptHashCollection.FindScript("Folder2/TestScript/TestScript.lua", Parent)).to.equal(Script2)
            expect(ScriptHashCollection.FindScript("Folder2/TestScript/TestScript.server.lua", Parent)).to.equal(Script3)
            expect(ScriptHashCollection.FindScript("Folder2/TestScript/TestScript.client.lua", Parent)).to.equal(Script4)
        end)

        it("should return scripts for init paths.", function()
            expect(ScriptHashCollection.FindScript("Folder2/TestScript/init.lua", Parent)).to.equal(Script1)
        end)
    end)

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
            expect(Collection.Hashes).to.deepEqual({
                ["Folder1/Folder2/TestScript1/init.lua"] = "0f91b5c398faf5a579ac42ec5096962c9d320438816d1c2d5df8f2e737e96dc2",
                ["Folder1/Folder2/TestScript1/TestScript2.lua"] = "11319e8661d9663c48c20f45450f282f2dff04d094a6ab34fe7c5dbdff9d6cee",
            })
        end)
    end)
end