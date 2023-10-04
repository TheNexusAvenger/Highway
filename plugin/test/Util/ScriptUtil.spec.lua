--[[
TheNexusAvenger

Tests the ScriptUtil.
--]]
--!strict

local ScriptUtil = require(game:GetService("ReplicatedStorage").HighwayPlugin.Util.ScriptUtil)

return function()
    describe("The CreateOrUpdate helper method", function()
        it("should update scripts.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local Script = Instance.new("ModuleScript")
            Script.Name = "Script"
            Script.Source = "return false"
            Script.Parent = Folder2

            ScriptUtil.CreateOrUpdate("Folder1/Folder2/Script.lua", "return true", Folder)
            expect(Script.Source).to.equal("return true")
        end)

        it("should use existing folders.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1

            ScriptUtil.CreateOrUpdate("Folder1/Folder2/Script.lua", "return true", Folder)
            expect((Folder2:FindFirstChild("Script") :: ModuleScript).Source).to.equal("return true")
        end)

        it("should create new folders.", function()
            local Folder = Instance.new("Folder")

            ScriptUtil.CreateOrUpdate("Folder1/Folder2/Script.lua", "return true", Folder)
            expect((Folder:FindFirstChild("Folder1") :: Folder).ClassName).to.equal("Folder")
            expect(((Folder:FindFirstChild("Folder1") :: Folder):FindFirstChild("Folder2") :: Folder).ClassName).to.equal("Folder")
            expect((((Folder:FindFirstChild("Folder1") :: Folder):FindFirstChild("Folder2") :: Folder):FindFirstChild("Script") :: ModuleScript).Source).to.equal("return true")
        end)

        it("should create init scripts.", function()
            local Folder = Instance.new("Folder")

            ScriptUtil.CreateOrUpdate("Folder1/Folder2/Script/init.lua", "return true", Folder)
            expect((Folder:FindFirstChild("Folder1") :: Folder).ClassName).to.equal("Folder")
            expect(((Folder:FindFirstChild("Folder1") :: Folder):FindFirstChild("Folder2") :: Folder).ClassName).to.equal("Folder")
            expect((((Folder:FindFirstChild("Folder1") :: Folder):FindFirstChild("Folder2") :: Folder):FindFirstChild("Script") :: ModuleScript).Source).to.equal("return true")
        end)

        it("should preserve children.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local Script = Instance.new("ModuleScript")
            Script.Name = "Script"
            Script.Source = "return false"
            Script.Parent = Folder2

            ScriptUtil.CreateOrUpdate("Folder1/init.lua", "return true", Folder)
            expect(Folder1.Parent).to.equal(nil)
            expect((Folder:FindFirstChild("Folder1") :: ModuleScript).Source).to.equal("return true")
            expect(((Folder:FindFirstChild("Folder1") :: ModuleScript):FindFirstChild("Folder2") :: Folder).ClassName).to.equal("Folder")
            expect((((Folder:FindFirstChild("Folder1") :: ModuleScript):FindFirstChild("Folder2") :: Folder):FindFirstChild("Script") :: ModuleScript).Source).to.equal("return false")
        
        end)
    end)

    describe("The Delete helper method", function()
        it("should delete scripts and unused folders.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local Script = Instance.new("ModuleScript")
            Script.Name = "Script"
            Script.Parent = Folder2

            ScriptUtil.Delete("Folder1/Folder2/Script.lua", Folder)
            expect(Folder1.Parent).to.equal(nil)
            expect(Folder2.Parent).to.equal(nil)
            expect(Script.Parent).to.equal(nil)
        end)

        it("should preserve non-empty folders folders.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Script1 = Instance.new("ModuleScript")
            Script1.Name = "Script1"
            Script1.Parent = Folder1
            local Folder2 = Instance.new("Folder")
            Folder2.Name = "Folder2"
            Folder2.Parent = Folder1
            local Script2 = Instance.new("ModuleScript")
            Script2.Name = "Script2"
            Script2.Parent = Folder2

            ScriptUtil.Delete("Folder1/Folder2/Script2.lua", Folder)
            expect(Folder1.Parent).to.equal(Folder)
            expect(Folder2.Parent).to.equal(nil)
            expect(Script1.Parent).to.equal(Folder1)
            expect(Script2.Parent).to.equal(nil)
        end)

        it("should preserve parent scripts.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Script1 = Instance.new("ModuleScript")
            Script1.Name = "Script1"
            Script1.Parent = Folder1
            local Script2 = Instance.new("ModuleScript")
            Script2.Name = "Script2"
            Script2.Parent = Script1

            ScriptUtil.Delete("Folder1/Script1/Script2.lua", Folder)
            expect(Folder1.Parent).to.equal(Folder)
            expect(Script1.Parent).to.equal(Folder1)
            expect(Script2.Parent).to.equal(nil)
        end)

        it("should preserve children.", function()
            local Folder = Instance.new("Folder")
            local Folder1 = Instance.new("Folder")
            Folder1.Name = "Folder1"
            Folder1.Parent = Folder
            local Script1 = Instance.new("ModuleScript")
            Script1.Name = "Script1"
            Script1.Parent = Folder1
            local Script2 = Instance.new("ModuleScript")
            Script2.Name = "Script2"
            Script2.Parent = Script1

            ScriptUtil.Delete("Folder1/Script1.lua", Folder)
            expect(Folder1.Parent).to.equal(Folder)
            expect(Script1.Parent).to.equal(nil)
            expect((Script2.Parent :: Folder).ClassName).to.equal("Folder")
            expect((Script2.Parent :: Folder).Name).to.equal("Script1")
            expect((Script2.Parent :: Folder).Parent).to.equal(Folder1)
        end)
    end)
end