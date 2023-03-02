local _, core = ...

local RaidExtended = core.RaidExtended

--Event listener
local EventFrame = CreateFrame('Frame', nil)
EventFrame:RegisterEvent("CHAT_MSG_CHANNEL")
EventFrame:RegisterEvent("CHAT_MSG_RAID")
EventFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
EventFrame:SetScript("OnEvent", function(...)
    local _, event, msg = ...
    local channel = select(11, ...)
    if (msg == "test" and (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER")) then
        SendChatMessage(RaidExtended.Durability:raidMessage(), "RAID")
    elseif (msg == "test" and channel == "world") then
        print("asdasd")
    end
end)