--[[
TheNexusAvenger

Frame for confirming and running pull actions.
--]]
--!strict

local PluginColor = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginColor"))
local PullAction = require(script.Parent.Parent.Parent:WaitForChild("Action"):WaitForChild("PullAction"))
local BasePromptFrame = require(script.Parent:WaitForChild("BasePromptFrame"))
local TextListEntry = require(script.Parent:WaitForChild("TextListEntry"))
local Types = require(script.Parent.Parent.Parent:WaitForChild("Types"))

local PullPromptFrame = BasePromptFrame:Extend()
PullPromptFrame:SetClassName("PullPromptFrame")

export type PullPromptFrame = {
    new: () -> (PullPromptFrame),
    Extend: (self: PullPromptFrame) -> (PullPromptFrame),
} & Types.BasePromptFrame



--[[
Loads the frame.
--]]
function PullPromptFrame:Load(): ()
    xpcall(function()
        --Create the action.
        local Action = PullAction.new()
        Action:PerformIntegrityCheck()
        Action:CalculateHashDifferences()
        
        --Determine the lines to display.
        local SecondaryColor = PluginColor.new(Enum.StudioStyleGuideColor.SubText):GetColor()
        local SecondaryColorText = "rgb("..tostring(math.floor(SecondaryColor.R * 255))..","..tostring(math.floor(SecondaryColor.G * 255))..","..tostring(math.floor(SecondaryColor.B * 255))..")"
        local Lines = {}
        for ScriptPath, HashDiffernece in Action.HashDifferences do
            local Hash = ""
            if HashDiffernece.Old and HashDiffernece.New then
                Hash = string.sub(HashDiffernece.Old, 1, 7).." -> "..string.sub(HashDiffernece.New, 1, 7)
            elseif HashDiffernece.New then
                Hash = string.sub(HashDiffernece.New, 1, 7)..", new"
            else
                Hash = "deleted"
            end
            table.insert(Lines, ScriptPath.." <font color=\""..SecondaryColorText.."\"><i>("..Hash..")</i></font>")
        end

        --Check if there are no lines to display.
        local ChangesToPull = true
        if #Lines == 0 then
            ChangesToPull = false
            table.insert(Lines, "<font color=\""..SecondaryColorText.."\"><i>No changes.</i></font>")
        end

        --Check that the code to pull is based on the latest changes.
        if ChangesToPull then
            --Build the list for the integrity check.
            local ErrorColor = PluginColor.new(Enum.StudioStyleGuideColor.ErrorText):GetColor()
            local ErrorColorText = "rgb("..tostring(math.floor(ErrorColor.R * 255))..","..tostring(math.floor(ErrorColor.G * 255))..","..tostring(math.floor(ErrorColor.B * 255))..")"
            local IntegrityLines = {}
            local IntegrityCheckPassed = true
            for ScriptPath, HashDiffernece in Action.IntegrityCheckHashes do
                local SystemHash = string.sub(tostring(HashDiffernece.Old), 1, 7)
                local StudioHash = HashDiffernece.New and string.sub(HashDiffernece.New, 1, 7) or "deleted"
                if SystemHash == StudioHash then
                    table.insert(IntegrityLines, ScriptPath.." <font color=\""..SecondaryColorText.."\"><i>("..SystemHash..")</i></font>")
                else
                    table.insert(IntegrityLines, "<font color=\""..ErrorColorText.."\">"..ScriptPath.."</font> <font color=\""..SecondaryColorText.."\"><i>("..SystemHash.." expected, got "..StudioHash..")</i></font>")
                    IntegrityCheckPassed = false
                end
            end

            --Display the integrity check if it failed.
            if not IntegrityCheckPassed then
                local ElementList = TextListEntry.CreateTextList(IntegrityLines)
                ElementList.Size = UDim2.new(1, 0, 1, -1)
                ElementList.Parent = self.ContentsFrame

                self.StatusText.Text = "System files not up to date. Push files and merge before pulling."
                self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
                return
            end
        end

        --Create the list.
        local ElementList = TextListEntry.CreateTextList(Lines)
        ElementList.Size = UDim2.new(1, 0, 1, -1)
        ElementList.Parent = self.ContentsFrame

        --Return if the game id is not allowed.
        if Action.Manifest.PushPlaceId and game.PlaceId ~= Action.Manifest.PushPlaceId then
            self.StatusText.Text = "Place id invalid for pushing ("..tostring(Action.Manifest.PushPlaceId).." required, got "..tostring(game.PlaceId)..")"
            self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
            return
        end

        --Return if there are no changes to pull.
        if not ChangesToPull then
            self.StatusText.Text = "No changes to pull."
            self.CancelButton.Text = "Close"
            return
        end

        --Connect the confirm button.
        local DB = true
        self.ConfirmButton.MouseButton1Click:Connect(function()
            if DB then
                DB = false
                xpcall(function()
                    --Disable the buttons.
                    self.ConfirmButton.Disabled = true
                    self.CancelButton.Disabled = true

                    --Pull the files.
                    self.StatusText.Text = "Applying changes..."
                    self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.MainText
                    Action:ApplyDifferences(function(Status: string)
                        self.StatusText.Text = Status
                    end)

                    --Complete the push.
                    self.StatusText.Text = "Pull complete."
                    self.CancelButton.Text = "Close"
                end, function(ErrorMessage: string)
                    --Display the error mesage.
                    self.StatusText.Text = ErrorMessage
                    self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText

                    --Allow using the buttons.
                    self.ConfirmButton.Disabled = false
                end)
                self.CancelButton.Disabled = false
                task.wait()
                DB = true
            end
        end)
        self.ConfirmButton.Disabled = false
        self.StatusText.Text = "Pull "..tostring(#Lines).." files?"
    end, function(ErrorMessage: string)
        --Display the error mesage.
        self.StatusText.Text = ErrorMessage
        self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
    end)
end



return (PullPromptFrame :: any) :: PullPromptFrame