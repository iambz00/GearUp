--[[ Global setting ]]--
local AddonName = ... -- "GearUp"
local GearUp = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0")
GearUp.name = AddonName
GearUp.dbname = "GearUpDB"
GearUp.version = GetAddOnMetadata(AddonName, "Version")
GearUp.versionstring = AddonName.. " v" ..GearUp.version
_G[AddonName] = GearUp
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(GearUp.name, true)

local NUM_MAX_EQUIPMENT_SETS = 10
local ui
local db = {}
local dropdownvalues = {}

-- Local print func
local function p(msg) print(L["GearUp"]..msg) end
local function pe(msg) print(L["GearUpErr"]..msg) end
local InCombatLockdown = InCombatLockdown
local UseEquipmentSet = UseEquipmentSet
local GetNumEquipmentSets = GetNumEquipmentSets
local GetEquipmentSetInfo = GetEquipmentSetInfo
local GetEquipmentSetInfoByName = GetEquipmentSetInfoByName
local defaults = {
	profile = {
		autoswap = true,
		showui = true,
		showanchor = true,
		setinfo = nil
	}
}

-- Key bindings
BINDING_HEADER_GEARUP = GearUp.name
BINDING_NAME_GEARUP1 = L["Equip set 1"]
BINDING_NAME_GEARUP2 = L["Equip set 2"]
BINDING_NAME_GEARUP3 = L["Equip set 3"]
BINDING_NAME_GEARUP4 = L["Equip set 4"]
BINDING_NAME_GEARUP5 = L["Equip set 5"]
BINDING_NAME_GEARUP6 = L["Equip set 6"]
BINDING_NAME_GEARUP7 = L["Equip set 7"]
BINDING_NAME_GEARUP8 = L["Equip set 8"]
BINDING_NAME_GEARUP9 = L["Equip set 9"]
BINDING_NAME_GEARUP10 = L["Equip set 10"]

--[[ Callbacks ]]--
function GearUp:OnInitialize()
	-- Init DB
	self.db = LibStub("AceDB-3.0"):New(self.dbname, defaults, false)
	db = self.db.profile
	-- After now, DO NOT use self.db, only use local 'db'

	-- Init UI and anchor
	self.ui = AceGUI:Create("Dropdown")
	ui = self.ui
	ui.anchor = CreateFrame("Frame", AddonName.."UIAnchor", ui.frame)
	ui.anchor:SetWidth(10)
	ui.anchor:SetHeight(10)
	ui.anchor:SetBackdrop{ bgFile = "Interface/Tooltips/UI-Tooltip-Background", }
	ui.anchor:SetBackdropColor(0,1,0,1)
	ui.anchor:SetPoint("CENTER", UIParent, "CENTER")
	ui.anchor:SetClampedToScreen(true)
	ui.anchor:SetMovable(true)
	ui.anchor:EnableMouse(true)
	ui.anchor:RegisterForDrag("LeftButton")
	ui.anchor:SetScript("OnEnter", function(self, ...) 
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:AddLine(L["ANCHOR_TOOLTIP"])
		GameTooltip:Show()
	end)
	ui.anchor:SetScript("OnLeave", function(self, ...) GameTooltip:Hide() end)
	ui.anchor:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			self:Hide()
			db.showanchor = false
		end
	end)
	ui.anchor:SetScript("OnDragStart", function(self, ...) self:StartMoving() end)
	ui.anchor:SetScript("OnDragStop", function(self, ...) self:StopMovingOrSizing()	end)
	ui.anchor:SetUserPlaced(true)

	ui:SetPoint("TOPLEFT", ui.anchor, "TOPRIGHT", 0, 2)
	ui:SetWidth(120)
	ui:SetCallback("OnValueChanged", function(widget, event, key) self:EquipSet(key) end)

	-- Build interface options
	self:BuildOptions() -- Build self.optionsTable
	LibStub("AceConfig-3.0"):RegisterOptionsTable(self.name, self.optionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name, self.name, nil, "General")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.name, L["Profiles"], self.name, "Profiles")
end

function GearUp:OnEnable()
	-- Build Spec list and equipment set list
	self:BuildSpecs()
	self:SetDropdownValues()
	db.setinfo = db.setinfo or self:BuildSetinfo()

	-- Equipment check
	local currentSetname = self:EquipmentCheck()

	-- Refresh UI and anchor
	ui.anchor:SetShown(db.showanchor)
	self:ToggleUI(db.showui)

	self:RegisterEvent("EQUIPMENT_SETS_CHANGED", "OnEquipSetChange")

	-- Register events
	if db.autoswap then
		self:SetAutoSwap(true)
		--self:OnSpecChange("OnEnable", GetSpecialization())
					-- or GetActiveSpecGroup()
	end
end

function GearUp:OnDisalbe()
	self:ToggleUI(false)
	self:SetAutoSwap(false)
	self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")
end

-- Event fired twice. Causes "You can't do that right now." error
function GearUp:OnSpecChange(event, after, before)
	local currentSpec = GetSpecialization()
	local setname = self.specs[currentSpec].name

	if IsAltKeyDown() then
		setname = setname.."@"
		p(L["Alt pressed! "]..L["Equip [%1] set"](setname))
	elseif IsControlKeyDown() then
		setname = setname.."^"
		p(L["Ctrl pressed! "]..L["Equip [%1] set"](setname))
	elseif IsShiftKeyDown() then
		setname = setname.."#"
		p(L["Shift pressed! "]..L["Equip [%1] set"](setname))
	else
		p(L["Equip [%1] set"](setname))
	end
	self:EquipSet(setname)
end

function GearUp:OnSwapFinish(event, success, setname)
	if success then
		p(L["[%1] set equipped]"](setname))
		self:RefreshUI(setname)
	else
		pe(L["Failed to equip [%1] set. Check UI error message"](setname))
	end
	PlaySound("SPELLBOOKOPEN")
end

function GearUp:OnEquipSetChange()
	self:SetDropdownValues()
	self:RefreshUI()
end

--[[ Functions ]]--
function GearUp:SetAutoSwap(flag)
	if flag then
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "OnSpecChange")
		self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", "OnSwapFinish")
		p(L["Auto swap ON"])
	else
		self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:UnregisterEvent("EQUIPMENT_SWAP_FINISHED")
		p(L["Auto swap OFF"])
	end
end

function GearUp:ToggleUI(shown)
	if shown then
		ui.frame:Show()
		self:RegisterEvent("PLAYER_REGEN_ENABLED", function() ui:SetDisabled(false) end)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", function() ui:SetDisabled(true) end)
		self:RefreshUI()
	else
		ui.frame:Hide()
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	end
end

function GearUp:RefreshUI(setname)
	ui:SetList(dropdownvalues.ui)
	setname = setname or self:EquipmentCheck() or ""
	ui:SetValue(setname)
end


function GearUp:EquipSet(setname) -- name
	setname = setname or ""
	if InCombatLockdown() then
		PlaySound("GAMEERRORUNABLETOEQUIP")
		pe(L["IN COMBAT. Try after combat ends"])
		return false
	end
--[[  icon, setID, isEquipped, numItems, equippedItems, availableItems, missingItems, ignoredSlots = GetEquipmentSetInfoByName("name")
name, icon, setID, isEquipped, numItems, equippedItems, availableItems, missingItems, ignoredSlots = GetEquipmentSetInfo(index)
]]
	local _, _, isEquipped, _, _, _, missingItems, _ = GetEquipmentSetInfoByName(setname)
	if isEquipped then
		p(L["Already wearing [%1] set"](setname))
	else
		if not missingItems then
			PlaySound("GAMEERRORUNABLETOEQUIP")
			pe(L["Set [%1] doesn't exist"](setname))
			return false
		end
		UseEquipmentSet(setname)
		if missingItems and missingItems > 0 then
			pe(L["%1 items missing in [%2] set"](missingItems, setname))
		end
	end
end

function GearUp:EquipSetNum(setnum)
	local setname = db.setinfo[setnum] or ""
	if setname ~= "" then
		self:EquipSet(setname)
	end
end

--[[ Functions for initiate ]]--
	-- id, name, description, icon, background, role, primaryStat = GetSpecializationInfo(specIndex [, isInspect [, isPet [, _ [, sex]]]])
function GearUp:BuildSpecs()
	self.specs = {}
	for n = 1, GetNumSpecializations() do 
		local id, name, _, icon, _, role, _ = GetSpecializationInfo(n)
		self.specs[n] = {
			id = id,
			name = name,
			--icon = icon, -- "|TInterface\\Icons\\"..icon..":16|t" (| = \124)
			--role = role,
		}
	end
end

function GearUp:BuildSetinfo()
	local setinfo = {}
	for i = 1, NUM_MAX_EQUIPMENT_SETS do
		if i <= GetNumEquipmentSets() then
			setinfo[i] = GetEquipmentSetInfo(i)
		else
			setinfo[i] = ""
		end
	end
	return setinfo
end

function GearUp:EquipmentCheck()
	for i = 1, GetNumEquipmentSets() do
		local setname, _, _, isEquipped = GetEquipmentSetInfo(i)
		if isEquipped then
			return setname
		end
	end
	return nil
end

function GearUp:SetDropdownValues()
	dropdownvalues = { ui = {}, option = {} }
	for i = 1, GetNumEquipmentSets() do
		dropdownvalues.ui[GetEquipmentSetInfo(i)] = GetEquipmentSetInfo(i)
		dropdownvalues.option[GetEquipmentSetInfo(i)] = GetEquipmentSetInfo(i)
	end
	dropdownvalues.option[""] = L["Not assigned"]
	if GetNumEquipmentSets() == 0 then
		dropdownvalues.ui[""] = L["Not assigned"]
	end
end

function GearUp:BuildOptions()
    self.optionsTable = {
	name = self.name,
	type = "group",
	get = function(info) return db[info[#info]] end,
	set = function(info, value) db[info[#info]] = value end,
	args = {
		General = {
			type = "group",
			name = L["General"],
			order = 10,
			args = {
				header1 = {
					name = L["Header 1"],
					type = "header",
					order = 10
				},
				autoswap = {
					name = L["Auto swap on Spec change"],
					type = "toggle",
					set = function(info, value)
						db[info[#info]] = value
						self:SetAutoSwap(value)
					end,
					order = 11
				},
				desc1 = {
					name = L["Description 1"],
					type = "description",
					order = 12,
				},
				header2 = {
					name = L["Header 2"],
					type = "header",
					order = 20
				},
				showui = {
					name = L["Show Floating UI"],
					desc = L["Show Floating UI"],
					type = "toggle",
					set = function(info, value)
						db[info[#info]] = value
						self:ToggleUI(value)
					end,
					order = 21
				},
				showanchor = {
					name = L["Set UI movable"],
					desc = L["Set UI movable"],
					type = "toggle",
					set = function(info, value)
						db[info[#info]] = value
						self.ui.anchor:SetShown(value)
					end,
					order = 22
				},
				resetuipos = {
					name = L["Reset UI position"],
					desc = L["Reset UI position"],
					type = "execute",
					func = function()
						ui.anchor:ClearAllPoints()
						ui.anchor:SetPoint("CENTER", UIParent, "CENTER")
					end,
					order = 23
				},
				header3 = {
					name = L["Header 3"],
					type = "header",
					order = 30
				},
				desc3 = {
					name = L["Description 3"],
					type = "description",
					order = 31,
				},
				--[[	1-10 Like this in for loop
					set1 = {
						name = "Set 1",
						type = "select",
						style = "dropdown",
						values = dropdownvalues.option,
						order = 100 + 3,
						get = function(info) return db.setinfo[1] end,
						set = function(info, value) db.setinfo[1] = value end
					},
					key1 = {
						name = "",
						type = "keybinding",
						get = function(info) return GetBindingKey("GEARUP1") end,
						set = function() end,
						disabled = true,
						width = "double",
						order = 100 + 3 + 1
					},
				]]
			},
		},
		Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
	}
    }
	for i = 1, NUM_MAX_EQUIPMENT_SETS do
		local setinfo = {
			name = L["Equipment set %1"](i),
			type = "select",
			style = "dropdown",
			--values = dropdownvalues.option, -- dropdown consumes value table
			values = function() return dropdownvalues.option end,
			order = 100 + 3 * i,
			get = function(info) return db.setinfo[i] or "" end,
			set = function(info, value) db.setinfo[i] = value end,
		}
		local setinfokey = {
			name = "",
			type = "keybinding",
			get = function(info) return GetBindingKey("GEARUP"..i) end,
			set = function() end,
			disabled = true,
			width = "double",
			order = 100 + 3 * i + 1
		}
		self.optionsTable.args.General.args["set"..i] = setinfo
		self.optionsTable.args.General.args["key"..i] = setinfokey
	end

end