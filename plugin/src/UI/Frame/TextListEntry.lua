--[[
TheNexusAvenger

Entry is a list of text.
--]]
--!strict

local TextService = game:GetService("TextService")

local NexusPluginComponents = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"))
local PluginInstance = require(script.Parent.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Base"):WaitForChild("PluginInstance"))

local TextListEntry = PluginInstance:Extend()
TextListEntry:SetClassName("TextListEntry")

export type TextListEntry = {
    CreateTextList: (Entries: {string}) -> (PluginInstance.PluginInstance),
    new: () -> (TextListEntry),
    Extend: (self: TextListEntry) -> (TextListEntry),
    Update: (self: TextListEntry, Data: {Message: string}?) -> (),
} & PluginInstance.PluginInstance & Frame



--[[
Creates a text list from the given list of text to display.
--]]
function TextListEntry.CreateTextList(Entries: {string}): PluginInstance.PluginInstance
    --Create the scrolling frame and element list.
    local ScrollingFrame = NexusPluginComponents.new("ScrollingFrame")
    ScrollingFrame.BackgroundTransparency = 1
    
    local ElementList = NexusPluginComponents.new("ElementList", TextListEntry)
    ElementList.EntryHeight = 22
    ElementList.CurrentWidth = 200
    ElementList:ConnectScrollingFrame(ScrollingFrame)

    --Set the max width.
    for _, Entry in Entries do
        local TextSizeParameters = Instance.new("GetTextBoundsParams")
        TextSizeParameters.Text = string.gsub(Entry, "<[^>]+>", "")
        TextSizeParameters.Font = Font.fromEnum(Enum.Font.SourceSans)
        TextSizeParameters.Size = 14
        TextSizeParameters.Width = 20000

        local TextWidth = TextService:GetTextBoundsAsync(TextSizeParameters).X
        ElementList.CurrentWidth = math.max(ElementList.CurrentWidth, TextWidth)
    end

    --Set the entries.
    local NewEntries = {}
    for _, Entry in Entries do
        table.insert(NewEntries, {Message = Entry})
    end
    ElementList:SetEntries(NewEntries)

    --Return the scrolling frame.
    return ScrollingFrame
end

--[[
Creates the text entry.
--]]
function TextListEntry:__new(): ()
    PluginInstance.__new(self, "Frame")

    --Create the text.
    local TextLabel = PluginInstance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -6, 1, 0)
    TextLabel.Position = UDim2.new(0, 3, 0, 0)
    TextLabel.RichText = true
    TextLabel.Parent = self
    self:DisableChangeReplication("TextLabel")
    self.TextLabel = TextLabel
end

--[[
Updates the text.
--]]
function TextListEntry:Update(Data: {Message: string}?): ()
    if Data then
        self.TextLabel.Text = Data.Message
    else
        self.TextLabel.Text = ""
    end
end



return (TextListEntry :: any) :: TextListEntry