--[[
TheNexusAvenger

Utility for handling scripts.
--]]
--!strict

local ScriptEditorService = game:GetService("ScriptEditorService")

local PathUtil = require(script.Parent:WaitForChild("PathUtil"))

local ScriptUtil = {}



--[[
Creates or updates a script.
--]]
function ScriptUtil.CreateOrUpdate(ScriptPath: string, ScriptSource: string, Parent: Instance?): ()
    Parent = Parent or game
    
    local ExistingScript = PathUtil.FindScript(ScriptPath, Parent)
    if ExistingScript then
        --Update the script.
        ScriptEditorService:UpdateSourceAsync(ExistingScript, function()
            return ScriptSource
        end)
    else
        local NewScriptPath, ScriptType = PathUtil.GetInstancePath(ScriptPath)
        if not NewScriptPath or not ScriptType then return end

        --Create the folders to the script.
        local SplitPath = string.split(NewScriptPath, "/")
        local ScriptParent = Parent :: Instance
        for i = 1, #SplitPath - 1 do
            local Child = ScriptParent:FindFirstChild(SplitPath[i]) :: Instance
            if not Child then
                local NewChild = Instance.new("Folder")
                NewChild.Name = SplitPath[i]
                NewChild.Parent = ScriptParent
                Child = NewChild
            end
            ScriptParent = Child
        end

        --Determine if there is an existing folder to replace.
        --Folders may be created by the above step.
        local ScriptName = SplitPath[#SplitPath]
        local ExistingFolder = ScriptParent:FindFirstChild(ScriptName)
        if ExistingFolder and not ExistingFolder:IsA("Folder") then
            ExistingFolder = nil
        end

        --Create the script.
        local NewScript = Instance.new(ScriptType)
        NewScript.Name = ScriptName;
        (NewScript :: any).Source = ScriptSource
        NewScript.Parent = ScriptParent

        --Clear the existing folder.
        if ExistingFolder then
            for _, Child in ExistingFolder:GetChildren() do
                Child.Parent = NewScript
            end
            ExistingFolder:Destroy()
        end
    end
end

--[[
Deletes a script while preseving the contents.
--]]
function ScriptUtil.Delete(ScriptPath: string, Parent: Instance?): ()
    local ExistingScript = PathUtil.FindScript(ScriptPath, Parent)
    if ExistingScript then
        --Transfer children of the script.
        local ScriptParent = ExistingScript.Parent
        if #ExistingScript:GetChildren() > 0 then
            local NewFolder = Instance.new("Folder")
            NewFolder.Name = ExistingScript.Name
            NewFolder.Parent = ScriptParent

            for _, Child in ExistingScript:GetChildren() do
                Child.Parent = NewFolder
            end
        end

        --Destroy the script.
        ExistingScript:Destroy()

        --Clear parent folders that contain no children.
        while ScriptParent and ScriptParent:IsA("Folder") and #ScriptParent:GetChildren() == 0 do
            local NewParent = ScriptParent.Parent
            ScriptParent:Destroy()
            ScriptParent = NewParent
        end
    end
end



return ScriptUtil