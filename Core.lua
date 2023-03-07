local _, core = ...

local Table = core.Table

function Table:InsertPlayer(durability, cost, sender)
    if not self.players[sender] then
        self.players[sender] = {}
    end
    core.Durability:UpdatePlayerDurability(Table.players[sender], durability, cost)
    local totalDurability, totalCost = core.Durability:GetTotalDurabilityAndCost()
    local fontString = _G["REDurabilityFrameOuputFrame"].Text
    core.Durability:SetDurabilityFrameText(totalDurability, totalCost, fontString)
end

function Table:UpdatePlayerTable()
    for name, _ in pairs(self.players) do
        local found = self:FindPlayer(name)
        if not found then
            self.players[name] = nil
        end
    end
end

function Table:FindPlayer(name)
    for i=1, GetNumGroupMembers() do
        print(name.." =? "..GetUnitName("raid"..i, true))
        if name == GetUnitName("raid"..i, true) then
            return true
        end
    end
    return false
end

--Event listener
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:SetScript("OnEvent", function(_, event, ...)
    local prefix = ...
    RegisterAddonMessagePrefix(core.prefix)

    if event == "CHAT_MSG_ADDON" and prefix == core.prefix then
        local msg, channel, sender = select(2, ...)
        print(sender)
        if channel == "RAID" and msg == "DurabilityRequest" then
            core.Durability:SendPlayerDurability()
        elseif channel == "RAID" then
            local durability, cost = strsplit(" ", msg)
            Table:InsertPlayer(durability, cost, sender)
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        Table:UpdatePlayerTable()
    end
end)