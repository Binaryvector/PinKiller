PinKiller = {}

-- there are two functions which can be used to hide floating pins, one is
-- SetFloatingMarkerGlobalAlpha
-- which can be used to hide all floating pins, by setting the alpha to 0
-- the other function is
-- SetFloatingMarkerInfo
-- which is used to set each pin types texture (ie behind a door etc)
-- when we pass nil as a texture name, the floating pins of the given pin type
-- will become insivible.


-- these are the pin types which can be seen floating in the 3d world
PinKiller.floatingPins = {
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = {"EsoUI/Art/FloatingMarkers/quest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door_assisted.dds"},
	
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon_assisted.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door_assisted.dds"},

	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = {"EsoUI/Art/FloatingMarkers/quest_icon.dds", "EsoUI/Art/FloatingMarkers/quest_icon_door.dds"},
	
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_icon.dds", "EsoUI/Art/FloatingMarkers/repeatableQuest_icon_door.dds"},
	
	[MAP_PIN_TYPE_TIMELY_ESCAPE_NPC] = {"EsoUI/Art/FloatingMarkers/timely_escape_npc.dds", "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds"},
	-- dark brotherhood pins are a bit weird.
	-- they are a type of quest condition pin, so when we do not set a brotherhood texture,
	-- then the pin will be a questcondition texture instead
--	[MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET] = {"EsoUI/Art/FloatingMarkers/timely_escape_npc.dds", "EsoUI/Art/FloatingMarkers/timely_escape_npc.dds"},
	
	[MAP_PIN_TYPE_QUEST_OFFER] = {"EsoUI/Art/FloatingMarkers/quest_available_icon.dds", "", true},
	[MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE] = {"EsoUI/Art/FloatingMarkers/repeatableQuest_available_icon.dds", "", true},
}

-- we overwrite the SetFloatingMarkerInfo function, so only the PinKiller addon can
-- change a floating pin's texture
-- overwriting this function is important to prevent the game from crashing, as
-- it is only allowed to be called ONCE for each pin type after a reloadui
local oldSetFloatingMarkerInfo = SetFloatingMarkerInfo
SetFloatingMarkerInfo = function(pinType, ...)
	-- abort, if this is a pin handled by the addon
	if PinKiller.floatingPins[pinType] then return end
	-- some addons change group member pins etc,
	-- so call the original function if the pinType is not handled by our addon
	oldSetFloatingMarkerInfo(pinType, ...)
end
local SetFloatingMarkerInfo = oldSetFloatingMarkerInfo

-- save the original animation. we will overwrite the animation later, if quest areas
-- should be hidden on the compass
local areaAnimation = COMPASS.PlayAreaPinOutAnimation

local ASSISTED = 10 -- assisted pin types are 7,8,9 (white quest markers instead of black ones)
-- I use the comparison "pinType < ASSISTED" to check if a pin type is assisted
local function IsPinTypeAssisted(pinType)
	return pinType < ASSISTED
end

-- these are the pin types we may want to hide on the compass
PinKiller.compassPins = {
	MAP_PIN_TYPE_QUEST_OFFER,
	MAP_PIN_TYPE_TRACKED_QUEST_CONDITION,
	MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_TRACKED_QUEST_ENDING,
	MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_ENDING,
	
	MAP_PIN_TYPE_QUEST_OFFER_REPEATABLE,
	MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION,
	MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING,
	MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION,
	MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING,
	
	MAP_PIN_TYPE_POI_SEEN,
	MAP_PIN_TYPE_POI_COMPLETE,
	MAP_PIN_TYPE_TIMELY_ESCAPE_NPC,
--	MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET,
}

-- pin types on the map which can be hidden by this addon
PinKiller.mapPins = {
	MAP_FILTER_QUESTS,
}


function PinKiller.SetCompassPin(pinType, visible)
	PinKiller.save.compass[pinType] = visible
	if visible then
		COMPASS.container:SetAlphaCoefficients(pinType, unpack(PinKiller.oldData[pinType][1]))
		COMPASS.container:SetMinVisibleAlpha(pinType, PinKiller.oldData[pinType][2]) 
	else
		COMPASS.container:SetAlphaCoefficients(pinType, 0, 0, 0)
		COMPASS.container:SetMinVisibleAlpha(pinType, 1) 
	end
end

function PinKiller.SetCompassPins()
	for _, tag in pairs(PinKiller.compassPins) do
		PinKiller.SetCompassPin(tag, PinKiller.save.compass[tag])
	end
	PinKiller.SetAreaAnimation(PinKiller.save.areaAnimation)
end

function PinKiller.SetAreaAnimation(value)
	PinKiller.save.areaAnimation = value
	if value then
		COMPASS.PlayAreaPinOutAnimation = areaAnimation
	else
		COMPASS.PlayAreaPinOutAnimation = COMPASS.StopAreaPinOutAnimation
	end
	COMPASS:PerformFullAreaQuestUpdate()
end

function PinKiller.SetFloatingPin(tag, door, value)
	PinKiller.save.floating[door][tag] = value
	local layout = PinKiller.floatingPins[tag]
	local INSIDE = true
	local OUTSIDE = false
	local tex, texdoor = "", ""
	if PinKiller.save.floating[OUTSIDE][tag] then
		tex = layout[1]
	end
	if PinKiller.save.floating[INSIDE][tag] then
		texdoor = layout[2]
		if not PinKiller.save.floating[OUTSIDE][tag] then
			-- in order for the "behind the door" pins to be displayed,
			-- the outside pins need to have a texture assigned
			-- so use this empy texture instead of an empty string
			tex = "PinKiller/empty.dds"
		end
	end
	
	local pulses = PinKiller.floatingPins[tag][3]
	SetFloatingMarkerInfo(tag, 32, tex, texdoor, pulses)
end

function PinKiller.SetFloatingPins()
	local tex, texdoor, pulses
	local INSIDE = true
	local OUTSIDE = false
	for tag, layout in pairs(PinKiller.floatingPins) do
		tex = ""
		texdoor = ""
		pulses = layout[3]
		if PinKiller.save.floating[OUTSIDE][tag] then
			tex = layout[1]
		end
		if PinKiller.save.floating[INSIDE][tag] then
			texdoor = layout[2]
			if not PinKiller.save.floating[OUTSIDE][tag] then
				-- in order for the "behind the door" pins to be displayed,
				-- the outside pins need to have a texture assigned
				-- so use this empy texture instead of an empty string
				tex = "PinKiller/empty.dds"
			end
		end
		if tex ~= "" then -- only call the function if needed
			SetFloatingMarkerInfo(tag, 32, tex, texdoor, pulses)
		end
	end
	-- must be set, otherwise db kill targets get the usual quest target arrow if quest_condition pins are enabled
	SetFloatingMarkerInfo(MAP_PIN_TYPE_DARK_BROTHERHOOD_TARGET, 32, "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds", "EsoUI/Art/FloatingMarkers/darkbrotherhood_target.dds")
end

local function contains( table, value )
	for key, v in pairs(table) do
		if v == value then
			return key
		end
	end
	return nil
end

function PinKiller.OnAddonLoaded( _, addon )
	if addon ~= "PinKiller" then
		return
	end
	
	local default = {
		compass = {},
		floating = {[true] = {}, [false] = {}},
		world = {},
	}
	PinKiller.save = ZO_SavedVars:New("PinKiller_SavedVariables", 2, "settings", default)
	
	-- wait until addon loaded to override ZO function (it's called earlier and would result in a crash)
	local oldIsShown = ZO_WorldMap_IsPinGroupShown
	function ZO_WorldMap_IsPinGroupShown( pinTag )
		if contains(PinKiller.mapPins, pinTag) then
			if not PinKiller.save.world[pinTag] then
				return false
			end
		end
		return oldIsShown( pinTag )
	end
	-- save original settings
	PinKiller.oldData = {}
	for _,pinType in pairs(PinKiller.compassPins) do
		PinKiller.oldData[pinType] = {
			{COMPASS.container:GetAlphaCoefficients(pinType)},
			COMPASS.container:GetMinVisibleAlpha(pinType)
		}
	end
	PinKiller.SetCompassPins()
	PinKiller.InitializeOptions()
end

EVENT_MANAGER:RegisterForEvent("PinKiller", EVENT_ADD_ON_LOADED , PinKiller.OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent("PinKiller", EVENT_PLAYER_ACTIVATED , PinKiller.SetFloatingPins)
EVENT_MANAGER:UnregisterForEvent("ZO_FloatingMarkers", EVENT_PLAYER_ACTIVATED)
