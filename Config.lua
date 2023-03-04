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
            ["font"] = Config.Fonts.LifeCraft.object
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
function Config:init()
    reUI = reUI or Config:CreateUI()
end

--Returns nil if Frame provided doesn't exist or displays the frame
function Config:ShowUIFrame(frame)
    local frame = GetClickFrame(frame)
    self:HideChildFrames()
    if not (frame) then return nil else frame:Show() end
end

function Config:HideChildFrames()
    for _, frame in pairs(reUI.Frames) do frame:Hide() end
end

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
function Config:CreateButton(name, point, relativeTo, template, relativePoint, xOffset, yOffset, width, height, text, font, fontSize)
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
function Config:CreateFrame(name, template, width, height)
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
function Config:CreateFontStringWithText(frame, name, layer, template, size, point, relativeTo, relativePoint, text, xOffset, yOffset)
    local font = frame:CreateFontString(name, layer, template)
    font:SetFont(Config:GetActiveFontPath(), size, "OUTLINE")
    font:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    font:SetText(text)
    return font
end

--Default Menu constructor, it is not run if reUI is loaded from SavedVariables
function Config:CreateUI()
    --Parent Frame
    local UIConfig = CreateFrame("Frame")
    UIConfig.Frames = {}

    --Menu Frame and Widgets
    UIConfig.Frames.Menu = Config:CreateFrame("FRAME_MENU", "BasicFrameTemplateWithInset", 250, 250)
    ---@diagnostic disable-next-line: undefined-field
    local relativeTo, MenuFrame = UIConfig.Frames.Menu.TitleBg, UIConfig.Frames.Menu
    MenuFrame.Buttons = {}
    MenuFrame.Text = {}
    MenuFrame.Text.title = Config:CreateFontStringWithText(MenuFrame, "FRAME_MENU_TEXT_TITLE", "OVERLAY", nil, 18, "LEFT", relativeTo, "LEFT", "Raid Extended")
    MenuFrame.Buttons.GroupFinder = Config:CreateButton("FRAME_MENU_BUTTON_GROUPFINDER", "CENTER", MenuFrame, "GameMenuButtonTemplate", "TOP", 0, -60, 160, 30, "Group Finder", self:GetActiveFontPath(), 20)
    MenuFrame.Buttons.Interface = Config:CreateButton("FRAME_MENU_BUTTON_INTERFACE", "CENTER", MenuFrame, "GameMenuButtonTemplate", "TOP", 0, -100, 160, 30, "Interface", self:GetActiveFontPath(), 20)
    MenuFrame.Buttons.Config = Config:CreateButton("FRAME_MENU_BUTTON_CONFIG", "CENTER", MenuFrame, "GameMenuButtonTemplate", "TOP", 0, -140, 160, 30, "Config", self:GetActiveFontPath(), 20)

    --GroupFinder Frame and Widgets
    UIConfig.Frames.GroupFinder = Config:CreateFrame("FRAME_GROUPFINDER", "BasicFrameTemplateWithInset", 300, 400)
    ---@diagnostic disable-next-line: undefined-field
    local relativeTo, GroupFinderFrame = UIConfig.Frames.GroupFinder.TitleBg, UIConfig.Frames.GroupFinder
    GroupFinderFrame.title = Config:CreateFontStringWithText(GroupFinderFrame, "FRAME_GROUPFINDER_TEXT_TITLE", "OVERLAY", nil, 18, "LEFT", relativeTo, "LEFT", "RE GroupFinder")

    --Interface Frame and Widgets
    UIConfig.Frames.Interface = Config:CreateFrame("FRAME_INTERFACE", "BasicFrameTemplateWithInset", 500, 500)
    ---@diagnostic disable-next-line: undefined-field
    local relativeTo, InterfaceFrame = UIConfig.Frames.Interface.TitleBg, UIConfig.Frames.Interface
    InterfaceFrame.title = Config:CreateFontStringWithText(InterfaceFrame, "FRAME_INTERFACE_TEXT_TITLE", "OVERLAY", nil, 18, "LEFT", relativeTo, "LEFT", "RE Interface")

    --Config Frame and Widgets
    UIConfig.Frames.Config = Config:CreateFrame("FRAME_CONFIG", "BasicFrameTemplateWithInset", 300, 300)
    ---@diagnostic disable-next-line: undefined-field
    local relativeTo, ConfigFrame = UIConfig.Frames.Config.TitleBg, UIConfig.Frames.Config
    ConfigFrame.title = Config:CreateFontStringWithText(ConfigFrame, "FRAME_CONFIG_TEXT_TITLE", "OVERLAY", nil, 18, "LEFT", relativeTo, "LEFT", "RE Config")

    GroupFinderFrame:Hide()
    InterfaceFrame:Hide()
    ConfigFrame:Hide()
    MenuFrame:Hide()
    return UIConfig
end