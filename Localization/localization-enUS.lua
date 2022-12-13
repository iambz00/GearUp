local AddonName = ...

local L = LibStub('AceLocale-3.0'):NewLocale(AddonName, "enUS", true)
if not L then return end

-- Header for printed message
L["GearUpInfo"] = "|cff10f010■ GearUp|r - "
L["GearUpWarn"] = "|cfff0f010■ GearUp|r - "
L["GearUpErr"]  = "|cfff01010■ GearUp|r - "

-- Dropdown Menu
L["In combat"] = true

-- Messages
L["Description"] = [[Shift-Drag: Move frame
 - Lef Click: Equip set(Hold Shift to Switch to according spec)
 - Right Click: Save set (Hold Ctrl to Create set)
 - If [@MainSpecName] set exists, equip automatically on spec switch.
 - Ignore slots: Tabard, Shirt]]
L["[%1] Already equipped"]  = function(setName) return "["..setName.."] Already equipped" end
L["[%1] Equipped"]          = function(setName) return "["..setName.."] Equipped" end
L["[%1] Failed"]            = function(setName) return "["..setName.."] Failed" end

L["[%1] Reserved"]          = function(setName) return "["..setName.."] Reserved" end
L["[%1] %2 items missing"]  = function(setName, missingItems) return "["..setName.."] "..missingItems.." items missing" end
L["[%1] Doesn't exist"]     = function(setName) return "["..setName.."] Doesn't exist" end

L["Create set"]             = "Create new equipment set"
L["Save [%1]"]              = function(setName) return "Save ["..setName.."]" end
L["Spec changed {%1} (%2)"] = function(specName, points) return "Detected spec switch {"..specName.."} ("..points.." points)" end
L["Switch Spec %1 {%2}"]    = function(specID, specName) return "Hold Shift to switch Spec "..specID.." {"..specName.."}" end
