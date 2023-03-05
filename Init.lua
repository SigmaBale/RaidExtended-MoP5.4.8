local _, core = ...

---Slash commands parser, it will traverse core.commands table until it finds a function
local function HandleSlashCommand(str)
    if (#str == 0) then
        core.commands["help"]()
        return
    end

    
    --table where we store tokens
    local args = {}
    --regx that gets us tokens
    local regx = "[^%s]+"
    for token in string.gmatch(str, regx) do
        table.insert(args, token)
    end

    --current path in table we are traversing
    local path = core.commands

    for idx, arg in ipairs(args) do
        arg = string.lower(arg)
        if (path[arg]) then
            if(type(path[arg]) == "function") then
---@diagnostic disable-next-line: deprecated
                path[arg](unpack(args, idx+1))
                return
            elseif (type(path[arg]) == "table") then
---@diagnostic disable-next-line: cast-local-type
                path = path[arg]
            else
                core.commands["help"]()
                return
            end
        else
            core.commands["help"]()
            return
        end
    end
end

core.commands = {
    ["menu"] = function()
        core.Config:ShowUIFrame("REMenuFrame")
    end,

    ["help"] = function ()
        core:print("Down below are listed all RaidExtended commands")
        core:printHelp("/re /raidextended", "- show all commands")
        core:printHelp("/re menu", "- open main menu")
        core:printHelp("/re interface", "- open interface tab")
        core:printHelp("/re groupfinder", "- open group finder tab")
        core:printHelp("/re config", "- open configuration tab")
    end,

    ["groupfinder"] = function()
        core.Config:ShowUIFrame("REGroupFinderFrame")
    end,

    ["interface"] = function()
        core.Config:ShowUIFrame("REInterfaceFrame")
    end,

    ["config"] = function()
        core.Config:ShowUIFrame("REConfigFrame")
    end,
}

function core:printHelp(cmd_section, text_section)
    local text, commandsColor, trackerColor = core.Config:GetActiveThemeComponents()
    local prefix = string.format("|cff%s%s|r", trackerColor, "RaidExtended:")
    local command = string.format("|cff%s%s|r ", commandsColor, cmd_section)
    local reg_text = string.format("|cff%s%s|r", text.color, text_section)
    DEFAULT_CHAT_FRAME:AddMessage(prefix..command..reg_text)
end

function core:print(...)
    local _, _, trackerColor = core.Config:GetActiveThemeComponents()
    local prefix = string.format("|cff%s%s|r", trackerColor, "RaidExtended:")
    DEFAULT_CHAT_FRAME:AddMessage(string.format("%s%s", prefix, table.concat({...}, " ")))
end

function core:init()
    core.Config.init()
    SLASH_RaidExtended1 = "/re"
    SLASH_RaidExtended2 = "/raidextended"
    SlashCmdList.RaidExtended = HandleSlashCommand
    ChatFrame1:SetFontObject(self.Config:GetActiveTheme().text.font)
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, _, name)
    if name == "RaidExtended" then core:init() end
end)