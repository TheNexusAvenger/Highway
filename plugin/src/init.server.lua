--[[
TheNexusAvenger

Main script for the highway plugin.
--]]
--!strict

local PromptWindow = require(script:WaitForChild("UI"):WaitForChild("Window"):WaitForChild("PromptWindow"))
local PullPromptFrame = require(script:WaitForChild("UI"):WaitForChild("Frame"):WaitForChild("PullPromptFrame"))
local PushPromptFrame = require(script:WaitForChild("UI"):WaitForChild("Frame"):WaitForChild("PushPromptFrame"))



--Create the toolbar and buttons.
local HighwayToolbar = plugin:CreateToolbar("Highway")
local PushButton = HighwayToolbar:CreateButton("Push to Remote", "Pushes the current Studio scripts to the remote Git repository.", "") --TODO: Create icon
PushButton.ClickableWhenViewportHidden = true
local PullButton = HighwayToolbar:CreateButton("Pull from System", "Pushes the current Studio scripts to the remote Git repository.", "") --TODO: Create icon
PullButton.ClickableWhenViewportHidden = true

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

