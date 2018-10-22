local optionsTable = setmetatable({}, { __index = table })

local function addCompassCheckbox(display, tag)
	optionsTable:insert({
		type = "checkbox",
		name = display,
		tooltip = "Select to display "..display.." pins on the compass.",
		getFunc = function() return PinKiller.save.compass[tag] end,
		setFunc = function( value )
			PinKiller.SetCompassPin(tag, value)
		end,
		width = "full",
		default = false,
	})
end

local function addFloatingCheckbox(display, tag, door, w)
	local add = "."
	if door then
		add = ", if target is behind a door."
	end
	if not w then w = "half" end;
	optionsTable:insert({
		type = "checkbox",
		name = display,
		tooltip = "Select to display floating "..display.." pins in the world"..add,
		getFunc = function() return PinKiller.save.floating[door][tag] end,
		setFunc = function( value )
			PinKiller.SetFloatingPin(tag, door, value)
		end,
		width = w,
		default = false,
	})
end

function PinKiller.InitializeOptions()
	local panelData = {
		type = "panel",
		name = "PinKiller",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("PinKiller"),
		author = "Shinni",
		version = "1.11",
		registerForRefresh = false,
		registerForDefaults = true,
	}
	
	optionsTable:insert({
		type = "header",
		name = "Compass Pins Options"
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = "Area Animation",
		tooltip = "Select to display the Quest Area Animation.",
		getFunc = function() return PinKiller.save.areaAnimation end,
		setFunc = function( value )
			PinKiller.SetAreaAnimation(value)
		end,
		width = "full",
		default = false,
	})
	addCompassCheckbox('"Point Of Interest"', MAP_PIN_TYPE_POI_SEEN)
	addCompassCheckbox('"Completed Point Of Interest"', MAP_PIN_TYPE_POI_COMPLETE)
	addCompassCheckbox('"Timely Escape (TG passive)"', MAP_PIN_TYPE_TIMELY_ESCAPE_NPC)
	
	optionsTable:insert({
		type = "header",
		name = "Quest Compass Pins"
	})
	
	addCompassCheckbox('"Quest Offer"', MAP_PIN_TYPE_QUEST_OFFER)
	addCompassCheckbox('"Tracked Quest Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION)
	addCompassCheckbox('"Tracked Quest Optional Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION)
	addCompassCheckbox('"Tracked Quest Ending"', MAP_PIN_TYPE_ASSISTED_QUEST_ENDING)
	addCompassCheckbox('"Secondary Quest Condition"', MAP_PIN_TYPE_TRACKED_QUEST_CONDITION)
	addCompassCheckbox('"Secondary Quest Optional Condition"', MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION)
	addCompassCheckbox('"Secondary Quest Ending"', MAP_PIN_TYPE_TRACKED_QUEST_ENDING)
	
	optionsTable:insert({
		type = "header",
		name = "Repeatable Quest Compass Pins"
	})
	
	addCompassCheckbox('"Quest Offer"', MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE)
	addCompassCheckbox('"Tracked Quest Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION)
	addCompassCheckbox('"Tracked Quest Optional Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION)
	addCompassCheckbox('"Tracked Quest Ending"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING)
	addCompassCheckbox('"Secondary Quest Condition"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION)
	addCompassCheckbox('"Secondary Quest Optional Condition"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION)
	addCompassCheckbox('"Secondary Quest Ending"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING)
	
	optionsTable:insert({
		type = "header",
		name = "Map Pins Options"
	})
	
	optionsTable:insert({
		type = "checkbox",
		name = "Quest Pins",
		tooltip = "Select to display Quest Pins on the worldmap.",
		getFunc = function() return PinKiller.save.world[MAP_FILTER_QUESTS] end,
		setFunc = function( value )
			PinKiller.save.world[MAP_FILTER_QUESTS] = value
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end,
		width = "full",
		default = false,
	})
	
	optionsTable:insert({
		type = "header",
		name = "Floating Pins Options"
	})
	
	--[[
	optionsTable:insert({
		type = "description",
		text = "You have to type /reloadui for these changes to take effect!",
		width = "full",
	})
	]]
	
	addFloatingCheckbox('"Timely Escape (TG passive)"', MAP_PIN_TYPE_TIMELY_ESCAPE_NPC, false, "full")
	
	optionsTable:insert({
		type = "header",
		name = "Quest Floating Pins"
	})
	
	addFloatingCheckbox('"Quest Offer"', MAP_PIN_TYPE_QUEST_OFFER, false, "full")
	
	optionsTable:insert({
		type = "description",
		text = "Normal floating pins:",
		width = "half",
	})
	
	optionsTable:insert({
		type = "description",
		text = "Floating pins on doors:",
		width = "half",
	})
	
	addFloatingCheckbox('"Tracked Quest Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, false)
	addFloatingCheckbox('"Tracked Quest Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION, true)
	addFloatingCheckbox('"Tracked Quest Optional Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, false)
	addFloatingCheckbox('"Tracked Quest Optional Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION, true)
	addFloatingCheckbox('"Tracked Quest Ending"', MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, false)
	addFloatingCheckbox('"Tracked Quest Ending"', MAP_PIN_TYPE_ASSISTED_QUEST_ENDING, true)
	addFloatingCheckbox('"Secondary Quest Condition"', MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, false)
	addFloatingCheckbox('"Secondary Quest Condition"', MAP_PIN_TYPE_TRACKED_QUEST_CONDITION, true)
	addFloatingCheckbox('"Secondary Quest Optional Condition"', MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, false)
	addFloatingCheckbox('"Secondary Quest Optional Condition"', MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION, true)
	addFloatingCheckbox('"Secondary Quest Ending"', MAP_PIN_TYPE_TRACKED_QUEST_ENDING, false)
	addFloatingCheckbox('"Secondary Quest Ending"', MAP_PIN_TYPE_TRACKED_QUEST_ENDING, true)
	
	optionsTable:insert({
		type = "header",
		name = "Repeatable Quest Floating Pins"
	})
	
	addFloatingCheckbox('"Quest Offer"', MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE, false, "full")
	
	optionsTable:insert({
		type = "description",
		text = "Normal floating pins:",
		width = "half",
	})
	
	optionsTable:insert({
		type = "description",
		text = "Floating pins on doors:",
		width = "half",
	})
	
	addFloatingCheckbox('"Tracked Quest Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, false)
	addFloatingCheckbox('"Tracked Quest Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION, true)
	addFloatingCheckbox('"Tracked Quest Optional Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, false)
	addFloatingCheckbox('"Tracked Quest Optional Condition"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION, true)
	addFloatingCheckbox('"Tracked Quest Ending"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, false)
	addFloatingCheckbox('"Tracked Quest Ending"', MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING, true)
	addFloatingCheckbox('"Secondary Quest Condition"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, false)
	addFloatingCheckbox('"Secondary Quest Condition"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION, true)
	addFloatingCheckbox('"Secondary Quest Optional Condition"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, false)
	addFloatingCheckbox('"Secondary Quest Optional Condition"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION, true)
	addFloatingCheckbox('"Secondary Quest Ending"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, false)
	addFloatingCheckbox('"Secondary Quest Ending"', MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING, true)
	
	local LAM = LibStub("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("PinKillerControl", panelData)
	LAM:RegisterOptionControls("PinKillerControl", optionsTable)
end