local _, core = ...

local Table = core.Table
local Durability = core.Durability

---Debugging function for tables
function core.dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. core.dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function Table:InsertPlayer(durability, cost, sender)
    if not self.players[sender] then self.players[sender] = {} end
    self.players[sender].durability = durability
    self.players[sender].cost = cost

    local totalDurability, totalCost = Durability:GetTotalDurabilityAndCost()

    Durability:SetDurabilityFrameText(totalDurability, totalCost)
end

--TODO: setting value to nil instead of indexing into table
function Table:UpdatePlayers()
    for name, _ in pairs(self.players) do
        local found = self:FindPlayer(name)
        if not found then self.players[name] = nil end
    end
end

function Table:FindPlayer(name)
    for i=1, GetNumGroupMembers() do
        print(name.." =? "..GetUnitName("raid"..i, true))
        if name == GetUnitName("raid"..i, true) then return true end
    end
    return false
end

function Table:Clear()
    Table.players = {}
end

local function IsValid(prefix, channel)
    return prefix == core.prefix and (channel == "RAID" or channel == "PARTY")
end

--Event listener
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:SetScript("OnEvent", function(_, event, prefix, msg, channel, sender)
    RegisterAddonMessagePrefix(core.prefix)

    if event == "CHAT_MSG_ADDON" and IsValid(prefix, channel) then
        if msg == "DurabilityRequest" then
            Durability:SendPlayerDurability(true)
        else
            local durability, cost = strsplit(" ", msg)
            Table:InsertPlayer(durability, cost, sender)
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        if IsInGroup() then Table:UpdatePlayers()
        else
            Table:Clear()
            Durability:ClearFrameText()
        end
    end
end)