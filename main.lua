ItemTracker = ItemTracker or {}

function ItemTracker:ToggleMainFrame()
    if not mainFrame:IsShown() then
        mainFrame:Show()
    else
        mainFrame:Hide()
    end
end


if not ItemTrackerDB then
    ItemTrackerDB = {}
end

-- set the frame

local mainFrame = CreateFrame("Frame", "ItemTrackerMainFrame", UIParent, "BasicFrameTemplateWithInset")
mainFrame:SetSize(500,350)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
mainFrame.TitleBg:SetHeight(30)
mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
mainFrame.title:SetPoint("TOPLEFT", mainFrame.TitleBg, "TOPLEFT", 5, -3)
mainFrame.title:SetText("ItemTracker")
mainFrame:Hide()

-- make it movable 
mainFrame:EnableMouse(true)
mainFrame:SetMovable(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function(self)
                    self:StartMoving()
end)
mainFrame:SetScript("OnDragStop", function(self)
                    self:StopMovingOrSizing()
end)

mainFrame:SetScript("OnHide", function()
    PlaySound(808)
end)

-- set our name
mainFrame.playerName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.playerName:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 15, -35)
mainFrame.playerName:SetText("Personnage: " .. UnitName('player') .. " ".. "(Level :" ..UnitLevel("player")..")")

-- show npc deaths in frame +golds
mainFrame.totalPlayerKills = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.totalPlayerKills:SetPoint("TOPLEFT", mainFrame.playerName, "BOTTOMLEFT", 0 , -10)
mainFrame.totalPlayerKills:SetText("Total d'ennemis tués: " .. (ItemTrackerDB.kills or "0"))

mainFrame.totalCurrency = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.totalCurrency:SetPoint("TOPLEFT", mainFrame.totalPlayerKills, "BOTTOMLEFT", 0, -10)
mainFrame.totalCurrency:SetText("Total Currency Collected:")
mainFrame.currencyGold = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.currencyGold:SetPoint("TOPLEFT", mainFrame.totalCurrency, "BOTTOMLEFT", 10, -15)
mainFrame.currencyGold:SetText("|cFFFFD700Gold: |cFFFFFFFF" .. (ItemTrackerDB.gold or "0"))
mainFrame.currencySilver = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.currencySilver:SetPoint("TOPLEFT", mainFrame.currencyGold, "BOTTOMLEFT", 0, -15)
mainFrame.currencySilver:SetText("|cFFC7C7C7FSilver: |cFFFFFFFF" .. (ItemTrackerDB.silver or "0"))
mainFrame.currencyCopper = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
mainFrame.currencyCopper:SetPoint("TOPLEFT", mainFrame.currencySilver, "BOTTOMLEFT", 0, -15)
mainFrame.currencyCopper:SetText("|cFFD7BEA5Copper: |cFFFFFFFF" .. (ItemTrackerDB.copper or "0"))

mainFrame:SetScript("OnShow", function()
    PlaySound(808)
    mainFrame.totalPlayerKills:SetText("Total d'ennemis tués: " .. (ItemTrackerDB.kills or "0"))
    mainFrame.currencyGold:SetText("|cFFFFD700Gold: |cFFFFFFFF" .. (ItemTrackerDB.gold or "0"))
    mainFrame.currencySilver:SetText("|cFFC7C7C7FSilver: |cFFFFFFFF" .. (ItemTrackerDB.silver or "0"))
    mainFrame.currencyCopper:SetText("|cFFD7BEA5Copper: |cFFFFFFFF" .. (ItemTrackerDB.copper or "0"))
end)

-- call the addon frame 

SLASH_ITEMTRACKER1 = "/itemtracker"
SLASH_ITEMTRACKER2 = "/it"
SlashCmdList["ITEMTRACKER"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

table.insert(UISpecialFrames,"ItemTrackerMainFrame")


--  listener of npc deaths - partykill : mob killed by you and your party
local eventListenerFrame = CreateFrame("Frame", "ItemTrackerEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)
    local _, eventType = CombatLogGetCurrentEventInfo()

    if event == "COMBAT_LOG_EVENT_UNFILTERED" and ItemTrackerDB.settingsKeys.enableKillTracking then
        if eventType and eventType == "PARTY_KILL" then
            if not ItemTrackerDB.kills then
                ItemTrackerDB.kills = 1
            else 
                ItemTrackerDB.kills = ItemTrackerDB.kills + 1
            end
        end
    elseif event == "CHAT_MSG_MONEY" and ItemTrackerDB.settingsKeys.enableCurrencyTracking then
        local msg = ...
        local gold = tonumber(string.match(msg, "(%d+) Or")) or 0
        local silver = tonumber(string.match(msg, "(%d+) Argent")) or 0
        local copper = tonumber(string.match(msg, "(%d+) Bronze")) or 0

        ItemTrackerDB.gold = (ItemTrackerDB.gold or 0) + gold
        ItemTrackerDB.silver = (ItemTrackerDB.silver or 0) + silver
        ItemTrackerDB.copper = (ItemTrackerDB.copper or 0) + copper

        if ItemTrackerDB.copper >= 100 then
            ItemTrackerDB.silver = ItemTrackerDB.silver + math.floor(ItemTrackerDB.copper / 100)
            ItemTrackerDB.copper = ItemTrackerDB.copper % 100
        end
          
        if ItemTrackerDB.silver >= 100 then
            ItemTrackerDB.gold = ItemTrackerDB.gold + math.floor(ItemTrackerDB.silver / 100)
            ItemTrackerDB.silver = ItemTrackerDB.silver % 100
        end
    end 
    if mainFrame:IsShown() then
        mainFrame.totalPlayerKills:SetText("Total d'ennemis tués: " .. (ItemTrackerDB.kills or "0"))
        mainFrame.totalPlayerKills:SetText("Total Kills: " .. (ItemTrackerDB.kills or "0"))
        mainFrame.currencyGold:SetText("|cFFFFD700Gold: |cFFFFFFFF" .. (ItemTrackerDB.gold or "0"))
        mainFrame.currencySilver:SetText("|cFFC7C7C7Silver: |cFFFFFFFF" .. (ItemTrackerDB.silver or "0"))
        mainFrame.currencyCopper:SetText("|cFFD7BEA5Copper: |cFFFFFFFF" .. (ItemTrackerDB.copper or "0"))
    end
    
end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventListenerFrame:RegisterEvent("CHAT_MSG_MONEY")



