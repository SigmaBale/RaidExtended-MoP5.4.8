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

--Argument (boolean) dictates if we want to send our durability or just return in. 
--If arg is true then we send otherwise return the values.
function Durability:SendPlayerDurability(send)
    local current, maximum = self:getDurability()
    local percentage = GetPercentageDurability(current, maximum)
    local cost = GetRepairCost(current, maximum)
    if send == true then SendAddonMessage("__RE", percentage.." "..cost, "RAID")
    else return percentage, cost end
end

--TODO: Add additional parsing when API expands
function Durability:ReadMessage(msg, type)
    if type == "durability" then
        local durability, cost = strsplit(" ", msg)
        return tonumber(durability), tonumber(cost)
    else return nil end
end

function Durability:GetTotalDurabilityAndCost()
    local totalDurability, totalCost = self:SendPlayerDurability(false)
    local playerCount, lowest, name = 0, 100, "None"
    for key, player in pairs(core.Table.players) do
        if player.durability < lowest then
            lowest, name  = player.durability, key
        end
        totalDurability = totalDurability + player.durability
        totalCost = totalCost + player.cost
        playerCount = playerCount + 1
    end
    return totalDurability/(playerCount+1), totalCost, name, lowest
end

function Durability:SetDurabilityFrameText(durability, cost)
    local playerDurability, playerCost = self:SendPlayerDurability(false)
    local newDurability = durability or playerDurability
    local newCost = cost or playerCost

    local durabilityHexColor = self:GetDurabilityColor(newDurability)
    local goldHexColor = "ffd700"
    local text = format("|cff%s%d|r  -  %d|cff%sg|r", durabilityHexColor, newDurability, newCost, goldHexColor)
    print(text)
    _G["DurabilityOutputFrame"].Text:SetText(text)
end

function Durability:ClearFrameText()
    _G["DurabilityOutputFrame"].Text:SetText("")
end

function Durability:GetDurabilityColor(totalDurability)
    if totalDurability >= 66 and totalDurability <= 100 then
        return self.colors.green
    elseif totalDurability > 33 and totalDurability < 66 then
        return self.colors.yellow
    elseif totalDurability >= 0 and totalDurability <= 33 then
        return self.colors.red
    end
end