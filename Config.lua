--Core => namespace (core table)
local _, core = ...

core.Config = {}

local Config = core.Config
local REMenu

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
    if (self.Themes[str]) then self.Themes.active = str else return nil end
end

--Toggle RaidExtended Menu
function Config:ToggleMenu()
    REMenu = REMenu or Config:CreateMenu()
    REMenu:SetShown(not (REMenu:IsShown()))
end

---Generalized button creation function
---@param point AnchorPoint
---@param relativeFrame any
---@param relativePoint string
---@param xOffset number
---@param yOffset number
---@param width number
---@param height number
---@param font string
---@param fontSize number
---@param text any
function Config:CreateButton(point, relativeFrame, relativePoint, xOffset, yOffset, width, height, font, fontSize, text)
    local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate")
    btn:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
    btn:SetSize(width, height)
    btn:SetNormalFontObject("GameFontNormalLarge")
    btn:SetHighlightFontObject("GameFontHighlightLarge")
    btn.fontString = btn:GetFontString()
    btn.fontString:SetFont(font, fontSize, "OUTLINE")
    btn:SetText(text)
    return btn
end

--Generates Default Menu
function Config:CreateMenu()
    --Menu Frame
    UIConfig = CreateFrame("Frame", "RaidExtended_Menu", UIParent, "BasicFrameTemplateWithInset")
    UIConfig:SetSize(250, 250)
    UIConfig:SetPoint("CENTER", UIParent, "CENTER")
    UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")
    UIConfig.title:SetFont(self:GetActiveFontPath(), 18, "OUTLINE")
    ---@diagnostic disable-next-line: undefined-field
    UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0)
    UIConfig.title:SetText("RaidExtended")

    --Group Finder Button
    UIConfig.btnGroupFinder = Config:CreateButton("CENTER", UIConfig, "TOP", 0, -60, 160, 30, self:GetActiveFontPath(), 20, "Group Finder")

    --Interface Button
    UIConfig.btnInterface = Config:CreateButton("CENTER", UIConfig, "TOP", 0, -100, 160, 30, self:GetActiveFontPath(), 20, "Interface")

    --Config Button
    UIConfig.btnConfig = Config:CreateButton("CENTER", UIConfig, "TOP", 0, -140, 160, 30, self:GetActiveFontPath(), 20, "Config")

    UIConfig:Hide()
    return UIConfig
end