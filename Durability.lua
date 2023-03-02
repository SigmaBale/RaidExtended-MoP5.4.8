local _, core = ...

--Defining RaidExtended table because we want durability to be subtable (module)
--Load order goes Durability.lua > Core.lua, so this is why (might fix it later)
core.RaidExtended = {}

core.RaidExtended.Durability = {}

local Durability = core.RaidExtended.Durability

--Est. repair cost per durability point in gold (ignoring reputation discount)
Durability.repairCost = 0.27

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
function Durability.getPercentage(current, maximum)
    return math.floor(current/maximum*100)
end

--Gets estimated repair cost in gold
function Durability:getRepairCost(current, maximum)
    return math.ceil((maximum - current)*(self.repairCost))
end

--String used as a raid message for all durability values
function Durability:raidMessage()
    local current, maximum = self:getDurability()
    local percentage = self.getPercentage(current, maximum)
    local cost = self:getRepairCost(current, maximum)
    return percentage.."% - ("..current.."/"..maximum.."), Repair: "..cost.."g"
end