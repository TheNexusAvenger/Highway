--[[
TheNexusAvenger

Main script for the highway plugin.
--]]
--!strict

local PluginToggleButton = require(script:WaitForChild("NexusPluginComponents"):WaitForChild("Input"):WaitForChild("Custom"):WaitForChild("PluginToggleButton"))
local PromptWindow = require(script:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("PromptWindow"))
local LiveSyncFrame = require(script:WaitForChild("UI"):WaitForChild("Frame"):WaitForChild("LiveSyncFrame"))
local PullPromptFrame = require(script:WaitForChild("UI"):WaitForChild("Frame"):WaitForChild("PullPromptFrame"))
local PushPromptFrame = require(script:WaitForChild("UI"):WaitForChild("Frame"):WaitForChild("PushPromptFrame"))



--Create the sync window.
local LiveSyncWindow = plugin:CreateDockWidgetPluginGui("Highway - Live Sync", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 300, 200, 160, 80))
LiveSyncWindow.Title = "Highway - Live Sync"
LiveSyncWindow.Name = "Highway - Live Sync"
LiveSyncFrame.new().Parent = LiveSyncWindow

--Create the toolbar and buttons.
local HighwayToolbar = plugin:CreateToolbar("Highway")
local PushButton = HighwayToolbar:CreateButton("Push to Remote", "Pushes the current Studio scripts to the remote Git repository.", "") --TODO: Create icon
PushButton.ClickableWhenViewportHidden = true
local PullButton = HighwayToolbar:CreateButton("Pull from System", "Pushes the current Studio scripts to the remote Git repository.", "") --TODO: Create icon
PullButton.ClickableWhenViewportHidden = true
local SyncButton = PluginToggleButton.new(HighwayToolbar:CreateButton("Sync Files", "Syncs files from the file system to Studio.", ""), LiveSyncWindow) --TODO: Create icon
SyncButton.ClickableWhenViewportHidden = true

--Connect the buttons.
local DB = true
PushButton.Click:Connect(function()
    if DB then
        DB = false
        PromptWindow.new("Highway - Push", PushPromptFrame.new(), plugin)
        task.wait()
        PushButton:SetActive(false)
        DB = true
    end
end)

PullButton.Click:Connect(function()
    if DB then
        DB = false
        PromptWindow.new("Highway - Pull", PullPromptFrame.new(), plugin)
        task.wait()
        PullButton:SetActive(false)
        DB = true
    end
end)

