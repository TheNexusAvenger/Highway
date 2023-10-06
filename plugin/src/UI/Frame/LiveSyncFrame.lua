--[[
TheNexusAvneger

Frame for controlling live syncing.
--]]
--!strict

local NexusPluginComponents = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))
local PluginInstance = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))
local SyncAction = require(script.Parent.Parent.Parent:WaitForChild("Action"):WaitForChild("SyncAction"))

local LiveSyncFrame = PluginInstance:Extend()
LiveSyncFrame:SetClassName("LiveSyncFrame")

export type LiveSyncFrame = {
    new: () -> (LiveSyncFrame),
    Extend: (self: LiveSyncFrame) -> (LiveSyncFrame),
} & PluginInstance.PluginInstance & Frame



--[[
Creates a LiveSyncFrame object.
--]]
function LiveSyncFrame:__new(): ()
    PluginInstance.__new(self, "Frame")

    --Create the frames.
    local StatusText = NexusPluginComponents.new("TextLabel")
    StatusText.Size = UDim2.new(1, -20, 1, -40)
    StatusText.AnchorPoint = Vector2.new(0.5, 0)
    StatusText.Position = UDim2.new(0.5, 10, 0, 5)
    StatusText.Text = "Ready to connect."
    StatusText.TextSize = 16
    StatusText.TextWrapped = true
    StatusText.TextTruncate = Enum.TextTruncate.AtEnd
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = self
    self:DisableChangeReplication("StatusText")
    self.StatusText = StatusText

    local ActionButton = NexusPluginComponents.new("TextButton")
    ActionButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
    ActionButton.BorderColor3 = Enum.StudioStyleGuideColor.DialogButtonBorder
    ActionButton.Size = UDim2.new(0, 100, 0, 22)
    ActionButton.AnchorPoint = Vector2.new(0.5, 0)
    ActionButton.Position = UDim2.new(0.5, 0, 1, -30)
    ActionButton.Text = "Connect"
    ActionButton.TextSize = 16
    ActionButton.TextColor3 = Enum.StudioStyleGuideColor.DialogMainButtonText
    ActionButton.Parent = self
    self:DisableChangeReplication("ActionButton")
    self.ActionButton = ActionButton

    --Connect the button.
    local DB = true
    local CurrentAction: SyncAction.SyncAction? = nil
    local SyncActive = false
    ActionButton.MouseButton1Click:Connect(function()
        if DB then
            DB = false
            task.delay(0.1, function()
                DB = true
            end)

            if SyncActive then
                --End the sync.
                if CurrentAction then
                    CurrentAction:Stop()
                    CurrentAction = nil
                end
                SyncActive = false

                --Reset the text and button.
                StatusText.TextColor3 = Enum.StudioStyleGuideColor.MainText
                StatusText.Text = "Ready to connect."
                ActionButton.Text = "Connect"
                ActionButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
            else
                ActionButton.Text = "Cancel"
                ActionButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogButton

                SyncActive = true
                xpcall(function()
                    --Set the text.
                    StatusText.TextColor3 = Enum.StudioStyleGuideColor.MainText
                    StatusText.Text = "Connecting..."

                    --Create the action.
                    local NewAction = SyncAction.new()
                    if not SyncActive then
                        StatusText.Text = "Ready to connect."
                        ActionButton.Text = "Connect"
                        ActionButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
                        return
                    end
                    CurrentAction = NewAction

                    --Stop if the game id is not allowed to sync.
                    if NewAction.Manifest.SyncPlaceId and game.GameId ~= NewAction.Manifest.SyncPlaceId then
                        self.StatusText.Text = "Game id invalid for pushing ("..tostring(NewAction.Manifest.SyncPlaceId).." required, got "..tostring(game.GameId)..")"
                        self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
                        CurrentAction = nil
                        SyncActive = false
                        ActionButton.Text = "Connect"
                        ActionButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
                        return
                    end

                    --Run the sync.
                    StatusText.Text = "Syncing active."
                    NewAction:Run()
                end, function(ErrorMessage)
                    --Display the error.
                    if SyncActive then
                        StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
                        StatusText.Text = ErrorMessage
                        ActionButton.Text = "Connect"
                        ActionButton.BackgroundColor3 = Enum.StudioStyleGuideColor.DialogMainButton
                    end

                    --End the sync.
                    if CurrentAction then
                        CurrentAction:Stop()
                        CurrentAction = nil
                        SyncActive = false
                    end
                end)
            end
        end
    end)

    --Set the frame properties.
    self.BorderSizePixel = 1
    self.Position = UDim2.new(0, 1, 0, 1)
    self.Size = UDim2.new(1, -2, 1, -2)
end



return (LiveSyncFrame :: any) :: LiveSyncFrame