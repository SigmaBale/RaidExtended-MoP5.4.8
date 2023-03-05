--Core => namespace (core table)
local _, core = ...

core.Config = {}

local Config = core.Config

---Variable that either is asigned the return value of Config:CreateUI() (Frame object)
---or gets the value from SavedVariables "RaidExtendedDB"
local reUI

--Font names and data
Config.Fonts = {
    ["LifeCraft"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\LifeCraft_Font.ttf", 
        size = 14,
        --If font object already exists we use that instead of creating a new object with the same name
        object = _G["LifeCraft"] or CreateFont("LifeCraft"),
    },
    ["DiabloLight"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\DiabloLight.ttf", 
        size = 14,
        object = _G["DiabloLight"] or CreateFont("DiabloLight")
    },
    ["DiabloHeavy"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\DiabloHeavy.ttf", 
        size = 14,
        object = _G["DiabloHeavy"] or CreateFont("DiabloHeavy")
    },
    ["GolosTextRegular"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\GolosText-Regular.ttf", 
        size = 14,
        object = _G["GolosTextRegular"] or CreateFont("GolosTextRegular")
    },
    ["GolosTextMedium"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\GolosText-Medium.ttf", 
        size = 14,
        object = _G["GolosTextMedium"] or CreateFont("GolosTextMedium")
    },
    ["GolosTextBold"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\GolosText-Bold.ttf", 
        size = 14,
        object = _G["GolosTextBold"] or CreateFont("GolosTextBold")
    },
    ["UbuntuLight"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\Ubuntu-Light.ttf", 
        size = 14,
        object = _G["UbuntuLight"] or CreateFont("UbuntuLight")
    },
    ["UbuntuRegular"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\Ubuntu-Regular.ttf", 
        size = 14,
        object = _G["UbuntuRegular"] or CreateFont("UbuntuRegular")
    },
    ["TiltNeonRegular"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\TiltNeon-Regular.ttf", 
        size = 14,
        object = _G["TiltNeonRegular"] or CreateFont("TiltNeonRegular")
    },
    ["OswaldExtraLight"] = { 
        path = "Interface\\AddOns\\RaidExtended\\resources\\fonts\\Oswald-ExtraLight.ttf", 
        size = 14,
        object = _G["OswaldExtraLight"] or CreateFont("OswaldExtraLight")
    }
}

--Setting up fonts path and sizes for font objects
--If these fonts already existed in global namespace 
--we will overwrite their data with our own font path and size
for _, fontData in pairs(Config.Fonts) do
    fontData.object:SetFont(fontData.path, fontData.size)
end

local defaults = {
    theme = "Default"
}

--Themes
Config.Themes = {
    ["Default"] = {
        ["text"] = {
            ["color"] = "efe6d5",
            ["font"] = Config.Fonts.UbuntuLight.object
        },
        ["command"] = "e73213",
        ["tracker"] = "9dbeb7",
    },
    ["Mango"] = {
        ["text"] = {
            ["color"] = "fef031",
            ["font"] = Config.Fonts.GolosTextRegular.object
        },
        ["command"] = "bde902",
        ["tracker"] = "018558",
    },
    ["Ambition"] = {
        ["text"] = {
            ["color"] = "eaebea",
            ["font"] = Config.Fonts.UbuntuRegular.object
        },
        ["command"] = "d8323c",
        ["tracker"] = "0c0e0c",
    },
    ["JetBlue"] = {
        ["text"] = {
            ["color"] = "d7eaf3",
            ["font"] = Config.Fonts.TiltNeonRegular.object
        },
        ["command"] = "77b5d9",
        ["tracker"] = "14397d",
    },
    ["Futuristic"] = {
        ["text"] = {
            ["color"] = "a0fefb",
            ["font"] = Config.Fonts.OswaldExtraLight.object
        },
        ["command"] = "494fc1",
        ["tracker"] = "fd084a",
    },
    active = defaults.theme
}

--Returns font path from currently active theme
function Config:GetActiveFontPath()
    return select(1, self:GetActiveFontObject():GetFont())
end

--Returns font object from currently active theme
function Config:GetActiveFontObject()
    return self:GetActiveTheme().text.font
end

--Returns currently active theme table
function Config:GetActiveTheme()
    return self.Themes[self.Themes.active]
end

--Returns currently active theme components
function Config:GetActiveThemeComponents()
    local theme = self:GetActiveTheme()
    return theme.text, theme.command, theme.tracker
end

--Sets active theme, or returns nil on failure
function Config:SetTheme(str)
    local theme = self.Themes[str]
    if (theme) then theme.active = str else return nil end
end

--Create UI or load it from `SavedVariables`
function Config.init()
    reUI = reUI or Config:CreateUI()
end

--Returns nil if Frame provided doesn't exist or displays the frame
function Config:ShowUIFrame(str)
    local frame = GetClickFrame(str)
    self:HideUIFrames()
    if not frame then return nil else frame:Show() end
end

function Config.HideUIFrames()
    for _, frame in pairs(reUI.Frames) do frame:Hide() end
end

local RE = {}

---Generalized button widget function
---@param name? string
---@param point AnchorPoint
---@param relativeTo any
---@param template string
---@param relativePoint string
---@param xOffset? number
---@param yOffset? number
---@param width number
---@param height number
---@param text string
---@param font string
---@param fontSize number
function RE.CreateButton(name, point, relativeTo, template, relativePoint, xOffset, yOffset, width, height, text, font, fontSize)
    local btn = CreateFrame("Button", name, relativeTo, template)
    btn:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    btn:SetSize(width, height)
    btn:SetNormalFontObject("GameFontNormalLarge")
    btn:SetHighlightFontObject("GameFontHighlightLarge")
    if(font and fontSize) then
        btn:GetFontString():SetFont(font, fontSize, "OUTLINE")
    end
    btn:SetText(text)
    return btn
end

---Generalized frame widget function, does the same thing as `CreateFrame`
---and additionally sets the dimensions.
---@generic Tp
---@param name? string
---@param template? `Tp` | TemplateType
---@param width number
---@param height number
---@return Frame
function RE.CreateFrame(name, template, width, height)
    local UIFrame = CreateFrame("Frame", name, UIParent, template)
    UIFrame:SetSize(width, height)
    UIFrame:SetPoint("CENTER")
    return UIFrame
end

---Same thing as `CreateFontString`, additionally takes font from currently active theme and sets font point, size and text.
---@generic Tp
---@param name? string
---@param layer? DrawLayer
---@param template? `Tp` | TemplateType
---@param size number
---@param point AnchorPoint
---@param relativeTo any
---@param relativePoint any
---@param xOffset? number
---@param yOffset? number
---@param text string
---@return FontString
function RE.CreateFontStringWithText(frame, name, layer, template, size, point, relativeTo, relativePoint, text, xOffset, yOffset)
    local font = frame:CreateFontString(name, layer, template)
    font:SetFont(Config:GetActiveFontPath(), size, "OUTLINE")
    font:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    font:SetText(text)
    return font
end

--Hides variable amount of frames, primarily only used in CreateUI to hide all frames as default
function RE.HideFrames(...)
    for _, frame in ipairs({...}) do frame:Hide() end
end

local function ScrollFrame_OnMouseWheel(self, delta) 
    local newValue = self:GetVerticalScroll() - (delta * 5)
    if (newValue < 0) then
        newValue = 0
    elseif (newValue > self:GetVerticalScrollRange()) then
        newValue = self:GetVerticalScrollRange()
    end

    self:SetVerticalScroll(newValue)
end

--Default Menu constructor, it is not run if reUI is loaded from SavedVariables
function Config:CreateUI()
    --Parent Frame
    local UIConfig = CreateFrame("Frame")
    UIConfig.Frames = {}
    UIConfig.ScrollFrames = {}

    --Menu Frame and Widgets
    UIConfig.Frames.Menu = RE.CreateFrame("REMenuFrame", "UIPanelDialogTemplate", 250, 250)
    local MenuFrame = UIConfig.Frames.Menu
    MenuFrame.Buttons = {}
    MenuFrame.Text = {}
    --Title
    MenuFrame.Text.title = RE.CreateFontStringWithText(MenuFrame, "REMenuFrameTitle", "OVERLAY", nil, 15, "LEFT", REMenuFrameTitleBG, "LEFT", "Raid Extended", 5, -1)
    --Button - GroupFinder
    MenuFrame.Buttons.GroupFinder = RE.CreateButton("REGroupFinderButton", "CENTER", MenuFrame, "GameMenuButtonTemplate", "TOP", 0, -80, 160, 30, "Group Finder", self:GetActiveFontPath(), 20)
    MenuFrame.Buttons.GroupFinder:SetScript("OnClick", function() self:ShowUIFrame("REGroupFinderFrame") end)
    --Button - Interface
    MenuFrame.Buttons.Interface = RE.CreateButton("REInterfaceButton", "CENTER", MenuFrame.Buttons.GroupFinder, "GameMenuButtonTemplate", "TOP", 0, -60, 160, 30, "Interface", self:GetActiveFontPath(), 20)
    MenuFrame.Buttons.Interface:SetScript("OnClick", function() self:ShowUIFrame("REInterfaceFrame") end)
    --Button - Config
    MenuFrame.Buttons.Config = RE.CreateButton("REConfigButton", "CENTER", MenuFrame.Buttons.Interface, "GameMenuButtonTemplate", "TOP", 0, -60, 160, 30, "Config", self:GetActiveFontPath(), 20)
    MenuFrame.Buttons.Config:SetScript("OnClick", function() self:ShowUIFrame("REConfigFrame") end)

    --GroupFinder Frame and Widgets
    UIConfig.Frames.GroupFinder = RE.CreateFrame("REGroupFinderFrame", "UIPanelDialogTemplate", 300, 400)
    local GroupFinderFrame = UIConfig.Frames.GroupFinder
    --Title
    GroupFinderFrame.title = RE.CreateFontStringWithText(GroupFinderFrame, "REGroupFinderFrameeTitle", "OVERLAY", nil, 15, "LEFT", REGroupFinderFrameTitleBG, "LEFT", "RE GroupFinder", 5, -1)
    --Scroll Frame
    GroupFinderFrame.ScrollFrame = CreateFrame("ScrollFrame", "REGroupFinderScrollFrame", GroupFinderFrame, "UIPanelScrollFrameTemplate")
    local ScrollFrame = GroupFinderFrame.ScrollFrame
    ScrollFrame:SetSize(GroupFinderFrame:GetWidth(), GroupFinderFrame:GetHeight())
    ScrollFrame:SetPoint("TOPLEFT", REGroupFinderFrameDialogBG, "TOPLEFT", -3, -1)
    ScrollFrame:SetPoint("BOTTOMRIGHT", REGroupFinderFrameDialogBG, "BOTTOMRIGHT", 1, -3)
    --Scroll Bar
    local scrollBar = ScrollFrame.ScrollBar
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPRIGHT", ScrollFrame, "TOPRIGHT", -1, -20)
    scrollBar:SetPoint("BOTTOMRIGHT", ScrollFrame, "BOTTOMRIGHT", -1, 20)
    --Overloading/overwriting blizzard default OnMouseWheel widget event handler
    ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    
    --Child Frame
    ScrollFrame.ChildFrame = CreateFrame("Frame", "REScrollFrameChildFrame", ScrollFrame)
    local child = ScrollFrame.ChildFrame
    child:SetSize(ScrollFrame:GetWidth() - 5, ScrollFrame:GetHeight() + 100)
    ScrollFrame:SetScrollChild(child)

    --Interface Frame and Widgets
    UIConfig.Frames.Interface = RE.CreateFrame("REInterfaceFrame", "UIPanelDialogTemplate", 500, 500)
    local InterfaceFrame = UIConfig.Frames.Interface
    --Title
    InterfaceFrame.title = RE.CreateFontStringWithText(InterfaceFrame, "REInterfaceFrameTitle", "OVERLAY", nil, 15, "LEFT", REInterfaceFrameTitleBG, "LEFT", "RE Interface", 5, -1)

    --Config Frame and Widgets
    UIConfig.Frames.Config = RE.CreateFrame("REConfigFrame", "UIPanelDialogTemplate", 300, 300)
    local ConfigFrame = UIConfig.Frames.Config
    --Title
    ConfigFrame.title = RE.CreateFontStringWithText(ConfigFrame, "REConfigFrameTitle", "OVERLAY", nil, 15, "LEFT", REConfigFrameTitleBG, "LEFT", "RE Config", 5, -1)

    --Hiding them with another function other than `HideChildFrames` 
    --because HideChildFrames indexes into reUI table that is currently being created
    RE.HideFrames(GroupFinderFrame, ConfigFrame, InterfaceFrame)
    return UIConfig
end