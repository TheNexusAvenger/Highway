--[[
TheNexusAvenger

Window that contains a prompt.
--]]
--!strict

local PluginInstance = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local PromptWindow = PluginInstance:Extend()
PromptWindow:SetClassName("PromptWindow")

export type PromptWindow = {
    new: (Title: string, PromptFrame: Types.BasePromptFrame, Plugin: Plugin) -> (PromptWindow),
    Extend: (self: PromptWindow) -> (PromptWindow),
} & PluginInstance.PluginInstance & DockWidgetPluginGui



--[[
Creates a PromptWindow object.
--]]
function PromptWindow:__new(Title: string, PromptFrame: Types.BasePromptFrame, Plugin: Plugin): ()
    PluginInstance.__new(self, Plugin:CreateDockWidgetPluginGui(Title, DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, true, 600, 400, 400, 300)))
    self.Title = Title
    self.Name = Title

    --Set up the prompt.
    PromptFrame.Parent = self
    PromptFrame.CancelButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    --Listen to the window closing.
    self:GetPropertyChangedSignal("Enabled"):Connect(function()
        if self.Enabled then return end
        self:Destroy()
    end)

    --Load the prompt.
    task.spawn(function()
        PromptFrame:Load()
    end)
end



return (PromptWindow :: any) :: PromptWindow