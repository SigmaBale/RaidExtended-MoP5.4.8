local _, core = ...

local Table = core.Table
local Durability = core.Durability

function Table:RemovePlayer(name)
    self.players[name] = nil
end

function Table:GetPlayer(name)
    return self.players[name]
end

function Table:InsertPlayer(name, player)
    self.players[name] = player
    Durability:SetDurabilityFrameText(Durability:GetTotalDurabilityAndCost())
end

--TODO: setting value to nil instead of indexing into table
function Table:Update()
    for name, _ in pairs(self.players) do
        local inRaid = self:PlayerInRaid(name)
        if not inRaid then self:RemovePlayer(name) end
    end
end

--Helper method, automatically gets provided name from the table
function Table:PlayerInRaid(name)
    for i=1, GetNumGroupMembers() do
        print(name.." =? "..GetUnitName("raid"..i, true))
        print(GetUnitName("raid"..i, true))
        if name == GetUnitName("raid"..i, true) then return true end
    end
    return false
end

function Table:Clear()
    Table.players = {}
end

local Player = {}

function Player:new(durability, cost)
    local obj = {}
    setmetatable(obj, Player)
    self.__init = self
    obj.durability = durability
    obj.cost = cost
    return obj
end

function Player:Update(durability, cost)
    self.durability = durability
    self.cost = cost
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
            local player = Player:new(Durability:ReadMessage(msg, "durability"))
            Table:InsertPlayer(sender, player)
            print(core.dump(Table))
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        if IsInGroup() then
            Table:Update()
            print(core.dump(Table))
        else
            Table:Clear()
            Durability:ClearFrameText()
            print(core.dump(Table))
        end
    end
end)

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