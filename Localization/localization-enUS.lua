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
L["Description"] = "Create/Delete set on Equipment manager window.\n - Shift-Drag: Move frame\n - Left Click: Equip set\n - Right Click: Save set(without Tabard, Shirt)"
L["[%1] Already equipped"]  = function(setName) return "["..setName.."] Already equipped" end
L["[%1] Equipped"]          = function(setName) return "["..setName.."] Equipped" end
L["[%1] Failed"]            = function(setName) return "["..setName.."] Failed" end

L["[%1] Reserved"]          = function(setName) return "["..setName.."] Reserved" end
L["[%1] %2 items missing"]  = function(setName, missingItems) return "["..setName.."] "..missingItems.." items missing" end
L["[%1] Doesn't exist"]     = function(setName) return "["..setName.."] Doesn't exist" end

L["Save [%1]"]              = function(setName) return "Save ["..setName.."]" end
L["Talent changed [%1] (%2)"] = function(specName, points) return "Talent changed ["..specName.."] ("..points.." points)" end
