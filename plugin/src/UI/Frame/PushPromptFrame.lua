--[[
TheNexusAvenger

Frame for confirming and running push actions.
--]]
--!strict

local HEIGHT_PER_INPUT_LABEL = 28
local INPUT_LABELS = {
    {
        Name = "CheckoutBranch",
        DisplayName = "Checkout Branch",
    },
    {
        Name = "PushBranch",
        DisplayName = "Push Branch",
    },
    {
        Name = "CommitMessage",
        DisplayName = "Commit Message",
    },
}

local NexusPluginComponents = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))
local PluginColor = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginColor"))
local PushAction = require(script.Parent.Parent.Parent:WaitForChild("Action"):WaitForChild("PushAction"))
local PathUtil = require(script.Parent.Parent.Parent:WaitForChild("Util"):WaitForChild("PathUtil"))
local BasePromptFrame = require(script.Parent:WaitForChild("BasePromptFrame"))
local TextListEntry = require(script.Parent:WaitForChild("TextListEntry"))

local PushPromptFrame = BasePromptFrame:Extend()
PushPromptFrame:SetClassName("PushPromptFrame")

export type PushPromptFrame = {
    new: () -> (PushPromptFrame),
    Extend: (self: PushPromptFrame) -> (PushPromptFrame),
} & BasePromptFrame.BasePromptFrame



--[[
Loads the frame.
--]]
function BasePromptFrame:Load(): ()
    xpcall(function()
        --Create the action.
        local Action = PushAction.new()

        --Determine the lines to display.
        local Lines = {}
        local SecondaryColor = PluginColor.new(Enum.StudioStyleGuideColor.SubText):GetColor()
        local SecondaryColorText = "rgb("..tostring(math.floor(SecondaryColor.R * 255))..","..tostring(math.floor(SecondaryColor.G * 255))..","..tostring(math.floor(SecondaryColor.B * 255))..")"
        for Script, Hash in Action.ScriptHashCollection.Hashes do
            table.insert(Lines, PathUtil.GetScriptPath(Script).." <font color=\""..SecondaryColorText.."\"><i>("..string.sub(Hash, 1, 7)..")</i></font>")
        end

        --Create the user interface.
        local ScrollListContainer = NexusPluginComponents.new("Frame")
        ScrollListContainer.BorderSizePixel = 1
        ScrollListContainer.Size = UDim2.new(1, 0, 1, -((HEIGHT_PER_INPUT_LABEL * #INPUT_LABELS) + 1))
        ScrollListContainer.Parent = self.ContentsFrame

        local ElementList = TextListEntry.CreateTextList(Lines)
        ElementList.Size = UDim2.new(1, 0, 1, 0)
        ElementList.Parent = ScrollListContainer

        local Labels = {}
        for i, InputLabelData in INPUT_LABELS do
            local BasePositionY = HEIGHT_PER_INPUT_LABEL * (#INPUT_LABELS - i)

            local LabelDisplayText = NexusPluginComponents.new("TextLabel")
            LabelDisplayText.Size = UDim2.new(0, 120, 0, 22)
            LabelDisplayText.AnchorPoint = Vector2.new(0, 0.5)
            LabelDisplayText.Position = UDim2.new(0, 10, 1, -(BasePositionY + (HEIGHT_PER_INPUT_LABEL / 2)))
            LabelDisplayText.Text = InputLabelData.DisplayName
            LabelDisplayText.TextSize = 16
            LabelDisplayText.TextTruncate = Enum.TextTruncate.AtEnd
            LabelDisplayText.TextXAlignment = Enum.TextXAlignment.Left
            LabelDisplayText.Parent = self.ContentsFrame

            local LabelInput = NexusPluginComponents.new("TextBox")
            LabelInput.Size = UDim2.new(1, -140, 0, HEIGHT_PER_INPUT_LABEL - 4)
            LabelInput.AnchorPoint = Vector2.new(0, 0.5)
            LabelInput.Position = UDim2.new(0, 130, 1, -(BasePositionY + (HEIGHT_PER_INPUT_LABEL / 2)))
            LabelInput.Text = ""
            LabelInput.PlaceholderText = Action.Manifest.Git[InputLabelData.Name]
            LabelInput.TextSize = 16
            LabelInput.TextXAlignment = Enum.TextXAlignment.Left
            LabelInput.Parent = self.ContentsFrame
            Labels[InputLabelData.Name] = LabelInput
        end

        --Return if the game id is not allowed.
        if Action.Manifest.PushPlaceId and game.GameId ~= Action.Manifest.PushPlaceId then
            self.StatusText.Text = "Game id invalid for pushing ("..tostring(Action.Manifest.PushPlaceId).." required, got "..tostring(game.GameId)..")"
            self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
            return
        end

        --Connect the confirm button.
        local DB = true
        self.ConfirmButton.MouseButton1Up:Connect(function()
            if DB then
                DB = false
                xpcall(function()
                    --Disable the buttons.
                    self.ConfirmButton.Disabled = true
                    self.CancelButton.Disabled = true

                    --Determine the parameters.
                    local Parameters = {}
                    for InputName, InputBox in Labels do
                        local Parameter = (InputBox.Text == "" and InputBox.PlaceholderText or InputBox.Text)
                        if Parameter == "" then continue end
                        Parameters[InputName] = Parameter
                    end

                    --Export the files.
                    self.StatusText.Text = "Preparing scripts..."
                    self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.MainText
                    Action:PushScripts(Parameters.CheckoutBranch, Parameters.PushBranch, Parameters.CommitMessage, function(Status: string)
                        self.StatusText.Text = Status
                    end)

                    --Complete the push.
                    self.StatusText.Text = "Push complete."
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
        self.StatusText.Text = "Push "..tostring(#Lines).." files?"
    end, function(ErrorMessage: string)
        --Display the error mesage.
        self.StatusText.Text = ErrorMessage
        self.StatusText.TextColor3 = Enum.StudioStyleGuideColor.ErrorText
    end)
end



return (PushPromptFrame :: any) :: PushPromptFrame