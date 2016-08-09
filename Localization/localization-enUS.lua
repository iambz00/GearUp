--[[ global vars & metadata ]]--
local AddonName = ...

local L = LibStub('AceLocale-3.0'):NewLocale(AddonName, "enUS", true)
if not L then return end

-- Header for printed message
L["GearUp"] = "|cff10f010GearUp|r - "	-- Font color start w/ |cAARRGGBB(Alpha,R,G,B), end w/ |r
L["GearUpErr"] = "|cfff01010GearUp|r - "

-- Messages
L["Auto swap ON"] = true
L["Auto swap OFF"] = "Auto swap |cfff01010OFF|r"

L["Already wearing [%1] set"] = function(setname) return "Already wearing ["..setname.."] set" end
L["Equip [%1] set"] = function(setname) return "Equip ["..setname.."] set" end
L["[%1] set equipped]"] = function(setname) return "["..setname.."] set equipped]" end
L["Failed to equip [%1] set. Check UI error message"] = function(setname) return "Failed to equip ["..setname.."] set. Check UI error message" end

L["Alt pressed! "] = true
L["Ctrl pressed! "] = true
L["Shift pressed! "] = true

L["IN COMBAT. Try after combat ends"] = true
L["Set [%1] doesn't exist"] = function(setname) return "Set ["..setname.."] doesn't exist" end
L["%1 items missing in [%2] set"] = function(missingItems, setname) return missingItems.." items missing in ["..setname.."] set" end

-- UI Message 
L["Open Setting"] = true
L["ANCHOR_TOOLTIP"] = "|cff9090f0Drag|r to move anchor\n|cff9090f0Right click|r to hide anchor\nAnchor can be visible again in Interface Option"

-- Options Dialog
L["General"] = "Setting"
L["Profiles"] = true

L["Header 1"] = "Equipment Swap"
L["Description 1"] = "Wear equipment set has same name with spec.\nBefore finishing spec change, hold mod key to wear other sets.\nex> Alt - [specname@] / Ctrl - [specname^] / Shift - [specname#]"

L["Header 2"] = "UI & Position"

L["Header 3"] = "Keybind"
L["Description 3"] = "Assign keybind in Key setting menu"

L["Auto swap on Spec change"] = true
L["Show Floating UI"] = true
L["Show Floating UI - DESC"] = "Show wearing set name, Swap set"
L["Set UI movable"] = true
L["Set UI movable - DESC"] = "Show anchor again"
L["Reset UI position"] = true
L["Reset UI position - DESC"] = "Move to center of screen"

L["Equipment set %1"] = function(num) return "Equipment set "..num end
L["Not assigned"] = "|cfff0f010Not assigned|r"

-- Bind header
L["Equip set 1"] = true
L["Equip set 2"] = true
L["Equip set 3"] = true
L["Equip set 4"] = true
L["Equip set 5"] = true
L["Equip set 6"] = true
L["Equip set 7"] = true
L["Equip set 8"] = true
L["Equip set 9"] = true
L["Equip set 10"] = true
