local _, core = ...

core.Durability = {}

local Durability = core.Durability

Durability.colors = {
    red = "ff0000",
    yellow = "fff700",
    green = "00ff00"
}

--Est. repair cost per durability point in gold (ignoring reputation discount)
local RepairCost = 0.27

--Relevant inventory slots that have durability
Durability.inventorySlots = {
    INVSLOT_HEAD,
    INVSLOT_SHOULDER,
    INVSLOT_CHEST,
    INVSLOT_WAIST,
    INVSLOT_LEGS,
    INVSLOT_FEET,
    INVSLOT_WRIST,
    INVSLOT_HAND,
    INVSLOT_MAINHAND,
    INVSLOT_OFFHAND
}

--Checks and calculates durability for every equiped gear piece
--Returns current and maximum durability as durability points
function Durability:getDurability()
    local dur, max_dur = 0, 0
    for _, val in pairs(self.inventorySlots) do
        local current, maximum = GetInventoryItemDurability(val)
        if (current and maximum) then
            dur = dur + current
            max_dur = max_dur + maximum
        end
    end
    return dur, max_dur
end

--Gets current durability as percentage
local function GetPercentageDurability(current, maximum)
    return math.floor(current/maximum*100)
end

--Gets estimated repair cost in gold
local function GetRepairCost(current, maximum)
    return math.ceil((maximum - current)*(RepairCost))
end

function Durability.RequestDurability()
    SendAddonMessage(core.prefix, "DurabilityRequest", "RAID")
end

function Durability:PlayerDurability()
    local current, maximum = self:getDurability()
    local percentage = GetPercentageDurability(current, maximum)
    local cost = GetRepairCost(current, maximum)
    return percentage, cost
end

function Durability:SendPlayerDurability()
    local current, maximum = self:getDurability()
    local percentage = GetPercentageDurability(current, maximum)
    local cost = GetRepairCost(current, maximum)
    SendAddonMessage("__RE", percentage.." "..cost, "RAID")
end

function Durability:UpdatePlayerDurability(player, durability, cost)
    player.durability = durability
    player.cost = cost
end

function Durability:GetTotalDurabilityAndCost()
    local totalDurability, totalCost = self:PlayerDurability()
    for _, player in pairs(core.Table.players) do
        totalDurability = totalDurability + player.durability
        totalCost = totalCost + player.cost
    end 
    print(#core.Table.players+1)
    return totalDurability/(#core.Table.players+1), totalCost
end

function Durability:SetDurabilityFrameText(totalDurability, totalCost, fontString)
    local durabilityHexColor = self:DurabilityColor(totalDurability)
    local goldHexColor = "ffd700"
    print(totalDurability.." "..totalCost.." "..durabilityHexColor.." "..goldHexColor)
    local text = format("|cff%s%s|r  -  %s|cff%sg|r", durabilityHexColor, totalDurability, totalCost, goldHexColor)
    fontString:SetText(text)
end

function Durability:DurabilityColor(totalDurability)
    if totalDurability >= 66 and totalDurability <= 100 then
        return self.colors.green
    elseif totalDurability > 33 and totalDurability < 66 then
        return self.colors.yellow
    elseif totalDurability >= 0 and totalDurability <= 33 then
        return self.colors.red
    end
end