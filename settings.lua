local settings = {
    {
        settingText = "Activer le pistage des kills",
        settingKey = "enableKillTracking",
        settingTooltip = "Quand activé, comptabilise le nombre d'ennemis tués par vous ou votre équipe.",
    },
    {
        settingText = "Activer le pistage de la monnaie",
        settingKey = "enableCurrencyTracking",
        settingTooltip = "Quand activé, comptabilise la monnaie accumulée.",
    }

    
}

local checkboxes = 0

local function CreateCheckbox(checkboxText, key, checkboxTooltip)
    local checkbox = CreateFrame("CheckButton", "MyAddonCheckboxID" .. checkboxes, settingsFrame, "UICheckButtonTemplate")
    checkbox.Text:SetText(checkboxText)
    checkbox:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -30 + (checkboxes * -30))

    if ItemTrackerDB.settingsKeys[key] == nil then
        ItemTrackerDB.settingsKeys[key] = true
    end
    
    checkbox:SetChecked(ItemTrackerDB.settingsKeys[key])

    checkbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
    end)

    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    checkbox:SetScript("OnClick", function(self)
        ItemTrackerDB.settingsKeys[key] = self:GetChecked()
    end)

    checkboxes = checkboxes + 1

    return checkbox
end

-- frame 
local settingsFrame = CreateFrame("Frame", "ItemtrackerSettingsFrame", UIParent, "BasicFrameTemplateWithInset")
settingsFrame:SetSize(400, 300)
settingsFrame:SetPoint("CENTER")
settingsFrame.TitleBg:SetHeight(30)
settingsFrame.title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsFrame.title:SetPoint("CENTER", settingsFrame.TitleBg, "CENTER", 0, -3)
settingsFrame.title:SetText("ItemTracker Settings")
settingsFrame:Hide()
settingsFrame:EnableMouse(true)
settingsFrame:SetMovable(true)
settingsFrame:RegisterForDrag("LeftButton")
settingsFrame:SetScript("OnDragStart", function(self)
	self:StartMoving()
end)

settingsFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

--eventlistener

local eventListenerFrame = CreateFrame("Frame", "ItemtrackerSettingsEventListenerFrame", UIParent)

eventListenerFrame:RegisterEvent("PLAYER_LOGIN")

eventListenerFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if not ItemTrackerDB.settingsKeys then
            ItemTrackerDB.settingsKeys = {}
        end
    
        for _, setting in pairs(settings) do
            CreateCheckbox(setting.settingText, setting.settingKey, setting.settingTooltip)
        end
    end
end)


local addon = LibStub("AceAddon-3.0"):NewAddon("ItemTracker")
ItemTrackerMinimapButton = LibStub("LibDBIcon-1.0", true)

local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("ItemTracker", {
	type = "data source",
	text = "ItemTracker",
	icon = "Interface\\AddOns\\ItemTracker\\IT.tga",
	OnClick = function(self, btn)
        if btn == "LeftButton" then
		    MyAddon:ToggleMainFrame()
        elseif btn == "RightButton" then
            if settingsFrame:IsShown() then
                settingsFrame:Hide()
            else
                settingsFrame:Show()
            end
        end
	end,

	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end

		tooltip:AddLine("ItemTracker\n\nLeft-click: Open ItemTracker\nRight-click: Open ItemTracker Settings", nil, nil, nil, nil)
	end,
})

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("MyAddonMinimapPOS", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})

	MyAddonMinimapButton:Register("ItemTracker", miniButton, self.db.profile.minimap)
end

MyAddonMinimapButton:Show("ItemTracker")