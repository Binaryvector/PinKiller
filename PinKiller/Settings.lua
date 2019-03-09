
PinKiller = PinKiller or {}
PinKiller.version = "2.0"

function PinKiller:InitializeSettings()
	self:LoadSettings()
	self:InitializeLAM()
end

function PinKiller:LoadSettings()

	local defaultSettings = {
		disabledCompassPinTypes = {},
		disabledFloatingMarkerPinTypes = {},
		disabledFloatingMarkerBreadcrumbPinTypes = {},
		disabledMapPinGroups = {},
		disableAreaAnimation = false,
	}
	PinKiller.settings = ZO_SavedVars:New("PinKiller_SavedVariables", 3, "settings", defaultSettings)
	
end

function PinKiller:IsFloatingMarkerEnabled(pinType)
	return not self.settings.disabledFloatingMarkerPinTypes[pinType]
end

function PinKiller:IsFloatingMarkerBreadcrumbEnabled(pinType)
	return not self.settings.disabledFloatingMarkerBreadcrumbPinTypes[pinType]
end

function PinKiller:IsCompassPinTypeEnabled(pinType)
	return not self.settings.disabledCompassPinTypes[pinType]
end

function PinKiller:IsMapPinGroupEnabled(pinTag)
	return not self.settings.disabledMapPinGroups[pinTag]
end

function PinKiller:IsAreaPinAnimationEnabled()
	return not self.settings.disableAreaAnimation
end

function PinKiller:InitializeLAM()

	local function addCompassCheckbox(menuTable, pinType)
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		menuTable:insert({
			type = "checkbox",
			name = pinTypeName,
			tooltip = zo_strformat(self.strings.COMPASS_CHECKBOX_TOOLTIP, pinTypeName),
			getFunc = function() return not self.settings.disabledCompassPinTypes[pinType] end,
			setFunc = function(value)
				self.settings.disabledCompassPinTypes[pinType] = not value
				self:RefreshCompassPinSettings(pinType)
			end,
			width = "full",
			default = true,
		})
	end

	local function addFloatingCheckbox(menuTable, pinType, isBreadcrumb, width)
		width = width or "half"	
		local pinTypeName = self.strings.PIN_TYPE_NAMES[pinType]
		local tooltip, settingsTable
		if isBreadcrumb then
			tooltip = self.strings.FLOATING_MARKER_BREADCRUMB_CHECKBOX_TOOLTIP
			settingsTable = self.settings.disabledFloatingMarkerBreadcrumbPinTypes
		else
			tooltip = self.strings.FLOATING_MARKER_CHECKBOX_TOOLTIP
			settingsTable = self.settings.disabledFloatingMarkerPinTypes
		end
		
		menuTable:insert({
			type = "checkbox",
			name = pinTypeName,
			tooltip = zo_strformat(tooltip, pinTypeName),
			getFunc = function() return not settingsTable[pinType] end,
			setFunc = function(value)
				settingsTable[pinType] = not value
				self:RefreshFloatingMarkerInfo(pinType)
			end,
			width = width,
			default = true,
		})
	end

	local panelData = {
		type = "panel",
		name = "PinKiller",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("PinKiller"),
		author = "Shinni",
		version = self.version,
		registerForRefresh = false,
		registerForDefaults = true,
	}
	local optionsTable = setmetatable({}, { __index = table })
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.COMPASS_HEADER,
		controls = submenuTable,
	})
	
	submenuTable:insert({
		type = "checkbox",
		name = self.strings.AREA_ANIMATION,
		tooltip = self.strings.AREA_ANIMATION_TOOLTIP,
		getFunc = function() return not self.settings.disableAreaAnimation end,
		setFunc = function(value) self.settings.disableAreaAnimation = not value end,
		width = "full",
		default = false,
	})
	
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_POI_SEEN)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_POI_COMPLETE)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TIMELY_ESCAPE_NPC)
	
	submenuTable:insert({
		type = "header",
		name = self.strings.QUEST_HEADER,
	})
	
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ENDING)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_ENDING)
	
	submenuTable:insert({
		type = "header",
		name = self.strings.REPEATABLE_QUEST_HEADER,
	})
	
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION)
	addCompassCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING)
	
	optionsTable:insert({
		type = "header",
		name = self.strings.MAP_HEADER,
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = self.strings.QUEST_PINS,
		tooltip = self.strings.QUEST_PINS_TOOLTIP,
		getFunc = function() return not self.settings.disabledMapPinGroups[MAP_FILTER_QUESTS] end,
		setFunc = function(value)
			self.settings.disabledMapPinGroups[MAP_FILTER_QUESTS] = not value
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end,
		width = "full",
		default = true,
	})
	
	local submenuTable = setmetatable({}, { __index = table })
	optionsTable:insert({
		type = "submenu",
		name = self.strings.FLOATING_MARKER_HEADER,
		controls = submenuTable,
	})
	
	local isBreadcrumb = true
	local isNotBreadcrumb = false
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, isNotBreadcrumb, "full")
	
	submenuTable:insert({
		type = "header",
		name = self.strings.QUEST_HEADER,
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER, isNotBreadcrumb, "full")
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_NORMAL,
		width = "half",
	})
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_BREADCRUMB,
		width = "half",
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_ENDING, isBreadcrumb)
	
	submenuTable:insert({
		type = "header",
		name = self.strings.REPEATABLE_QUEST_HEADER,
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, isNotBreadcrumb, "full")
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_NORMAL,
		width = "half",
	})
	
	submenuTable:insert({
		type = "description",
		text = self.strings.FLOATING_BREADCRUMB,
		width = "half",
	})
	
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, isBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, isNotBreadcrumb)
	addFloatingCheckbox(submenuTable, MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, isBreadcrumb)
	
	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("PinKillerControl", panelData)
	LAM:RegisterOptionControls("PinKillerControl", optionsTable)
end