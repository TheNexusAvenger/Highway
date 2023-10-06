--[[
TheNexusAvenger

Base frame for pull/push actions.
--]]
--!strict

local BOTTOM_BAR_HEIGHT = 32

local NexusPluginComponents = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))
local PluginInstance = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))

local BasePromptFrame = PluginInstance:Extend()
BasePromptFrame:SetClassName("BasePromptFrame")

export type BasePromptFrame = {
    ContentsFrame: PluginInstance.PluginInstance,
    BottomBar: PluginInstance.PluginInstance,
    StatusText: PluginInstance.PluginInstance,
    ConfirmButton: PluginInstance.PluginInstance,
    CancelButton: PluginInstance.PluginInstance,

    new: () -> (BasePromptFrame),
    Extend: (self: BasePromptFrame) -> (BasePromptFrame),
    Load: (self: BasePromptFrame) -> (),
} & PluginInstance.PluginInstance & Frame



--[[
Creates a BasePromptFrame object.
--]]
function BasePromptFrame:__new(): ()
    PluginInstance.__new(self, "Frame")

    --Create the container.
    local ContentsFrame = NexusPluginComponents.new("Frame")
    ContentsFrame.Size = UDim2.new(1, 0, 1, -BOTTOM_BAR_HEIGHT)
    ContentsFrame.Position = UDim2.new(0, 0, 0, 0)
    ContentsFrame.Parent = self
    self:DisableChangeReplication("ContentsFrame")
    self.ContentsFrame = ContentsFrame

    --Create the bottom bar.
    local BottomBar = NexusPluginComponents.new("Frame")
    BottomBar.BorderSizePixel = 1
    BottomBar.Size = UDim2.new(1, 0, 0, BOTTOM_BAR_HEIGHT)
    BottomBar.Position = UDim2.new(0, 0, 1, -BOTTOM_BAR_HEIGHT)
    BottomBar.Parent = self
    self:DisableChangeReplication("BottomBar")
    self.BottomBar = BottomBar

    local StatusText = NexusPluginComponents.new("TextLabel")
    StatusText.Size = UDim2.new(1, -220, 0, 22)
    StatusText.AnchorPoint = Vector2.new(0, 0.5)
    StatusText.Position = UDim2.new(0, 10, 0.5, 0)
    StatusText.Text = "Loading..."
    StatusText.TextSize = 16
    StatusText.TextTruncate = Enum.TextTruncate.AtEnd
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = BottomBar
    self:DisableChangeReplication("StatusText")
    self.StatusText = StatusText

    local ConfirmButton = NexusPluginComponents.new("TextButton")
    ConfirmButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
    ConfirmButton.BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder
    ConfirmButton.Size = UDim2.new(0, 90, 0, 22)
    ConfirmButton.AnchorPoint = Vector2.new(0, 0.5)
    ConfirmButton.Position = UDim2.new(1, -200, 0.5, 0)
    ConfirmButton.Text = "Confirm"
    ConfirmButton.TextSize = 16
    ConfirmButton.TextColor3 = Enum.StudioStyleGuideColor.DialogMainButtonText
    ConfirmButton.Disabled = true
    ConfirmButton.Parent = BottomBar
    self:DisableChangeReplication("ConfirmButton")
    self.ConfirmButton = ConfirmButton

    local CancelButton = NexusPluginComponents.new("TextButton")
    CancelButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogButton
    CancelButton.BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder
    CancelButton.Size = UDim2.new(0, 90, 0, 22)
    CancelButton.AnchorPoint = Vector2.new(0, 0.5)
    CancelButton.Position = UDim2.new(1, -100, 0.5, 0)
    CancelButton.Text = "Cancel"
    CancelButton.TextSize = 16
    CancelButton.TextColor3 = Enum.StudioStyleGuideColor.DialogButtonText
    CancelButton.Parent = BottomBar
    self:DisableChangeReplication("CancelButton")
    self.CancelButton = CancelButton

    --Set the frame properties.
    self.BorderSizePixel = 1
    self.Position = UDim2.new(0, 1, 0, 1)
    self.Size = UDim2.new(1, -2, 1, -2)
end

--[[
Loads the frame.
--]]
function BasePromptFrame:Load(): ()

end



return (BasePromptFrame :: any) :: BasePromptFrame