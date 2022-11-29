local addonName, _ = ... 
GearUp = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
GearUp.name = addonName
GearUp.version = GetAddOnMetadata(addonName, "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(GearUp.name, true)

local NUM_MAX_EQUIPMENT_SETS = 10

-- Local func
local function p(msg, ...) print(L["GearUpInfo"]..msg, ...) end
local function pw(msg, ...) print(L["GearUpWarn"]..msg, ...) end
local function pe(msg, ...) print(L["GearUpErr"]..msg, ...) end
local InCombatLockdown = InCombatLockdown
local GetNumEquipmentSets = C_EquipmentSet.GetNumEquipmentSets

StaticPopupDialogs["GEARUP_SAVE_EQUIPMENTSET"] = {
    text = "%s",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function() GearUp:SaveEquipSet() end
}

SLASH_GEARUP1 = "/geq"
SlashCmdList["GEARUP"] = function(msg)
    GearUp:EquipSetByName(msg)
end

function GearUp:OnInitialize()
    self:InitUI()

    -- Equipment check
    self.ticker = C_Timer.NewTicker(3, function()
        if GetNumEquipmentSets() > 0 then   -- Early call returns 0
            self.ticker:Cancel()
        end
        self:EquipmentCheck()
        self:OnEquipSetChange()
    end, 5)
end

function GearUp:InitUI()
    local ui = CreateFrame("Button", self.name.."FloatingUI", UIParent, "BackdropTemplate")
    self.ui = ui
    ui:EnableMouse(true)
    ui:SetWidth(56)
    ui:SetHeight(18)
    ui:SetMovable(true)
    ui:SetBackdrop({
        bgFile = "Interface/TutorialFrame/TutorialFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    ui:SetBackdropBorderColor(1,1,1,0.3)
    ui:SetPoint("CENTER")

    ui.text = ui:CreateFontString()
    ui.text:SetAllPoints()
    ui.text:SetFontObject("GameFontNormal")
    ui.text:SetText("|cff00ff00GearUp|r ")
    ui.anchor = CreateFrame("Frame", self.name.."DropDownAnchor", ui) -- Invisible anchor (EasyMenu changes anchor size)
    ui.anchor:SetPoint("TOP", ui, "BOTTOM")

    ui:RegisterForDrag("LeftButton")
    ui:RegisterForClicks("LeftButtonDown", "RightButtonDown")

    ui:SetScript("OnEnter", function(...)
        p(L["Description"])
        ui:SetScript("OnEnter", nil)    -- notice just once
    end)
    ui:SetScript("OnClick", function(s, btn)
        if btn == "LeftButton" and not IsShiftKeyDown() then
            GearUp:DropMenu()
        elseif btn == "RightButton" then
            if not InCombatLockdown() and GearUp.currentSet then
                local setName = GearUp:GetEquipmentSetInfo(GearUp.currentSet)
                StaticPopup_Show("GEARUP_SAVE_EQUIPMENTSET", L["Save [%1]"](setName))
            end
        end
    end)
    ui:SetScript("OnDragStart", function(s)
        if IsShiftKeyDown() then
            s:StartMoving()
        end
    end)
    ui:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
    end)
end

function GearUp:GetEquipmentSetInfo(setID, missingColor)
--  name, icon, setID, isEquipped, numItems, equippedItems, availableItems, missingItems, ignoredSlots = C_EquipmentSet.GetEquipmentSetInfo(index)
    if setID then
        local name, _, _, isEquipped, _, _, _, missingItems = C_EquipmentSet.GetEquipmentSetInfo(setID)
        if missingColor and missingItems and missingItems > 0 then
            name = "|cffe55451"..name.."|r"
        end
        return name, isEquipped, missingItems
    end
end

function GearUp:DropMenu()
    local menu = {}
    if InCombatLockdown() then
        table.insert(menu, {
            text = "|cffe55451"..L["In combat"].."|r",
            isTitle = true,
        })
    end
    for i = 0, GetNumEquipmentSets()-1 do
        local name, isEquipped = self:GetEquipmentSetInfo(i, true)
        if name then
            table.insert(menu, {
                text = name,
                value = i,
                checked = isEquipped,
                arg1 = i,
                registerForRightClick = true,
                func = function(_, setID) GearUp:EquipSet(setID) end
            })
        end
    end
    EasyMenu(menu, self.ui.text, self.ui.text, 0, 8)
end

function GearUp:SaveEquipSet()
    if self.currentSet then
        C_EquipmentSet.IgnoreSlotForSave(4)
        C_EquipmentSet.IgnoreSlotForSave(19)
        C_EquipmentSet.SaveEquipmentSet(self.currentSet)
    end
end

function GearUp:OnEnable()
    -- Register events
    self:RegisterEvent("EQUIPMENT_SETS_CHANGED", "OnEquipSetChange")
    self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", "OnSwapFinish")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "OnTalentChange")
end

function GearUp:OnDisalbe()
    self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")
    self:UnregisterEvent("EQUIPMENT_SWAP_FINISHED")
    self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
end

function GearUp:OnSwapFinish(event, success, setID)
    local setName = self:GetEquipmentSetInfo(setID, true)
    if success then
        p(L["[%1] Equipped"](setName))
        self:RefreshUI(setName)
    else
        pe(L["[%1] Failed"](setName))
    end
    SpellBookFrame_PlayOpenSound()
end

function GearUp:OnEquipSetChange()
    if GetNumEquipmentSets() > 0 then
        self.ui:Show()
    else
        self.ui:Hide()
    end
    self:RefreshUI(self:GetEquipmentSetInfo(self:EquipmentCheck(), true))
end

function GearUp:RefreshUI(text)
    if text then
        self.ui.text:SetText("|cffcccccc"..text.."|r")
    end
end

function GearUp:ReservedJob(event, unit)
    if      event == "PLAYER_REGEN_ENABLED" 
        or (event == "UNIT_SPELLCAST_STOP" and unit == "player")
        or (event == "UNIT_SPELLCAST_CHANNEL_STOP" and unit == "player")
    then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self:UnregisterEvent("UNIT_SPELLCAST_STOP")
        self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
        self:EquipSet(self.reserved)
    end
end

function GearUp:EquipSet(setID)
    local setName, isEquipped, missingItems = self:GetEquipmentSetInfo(setID, true)

    if InCombatLockdown() then
        pw(L["[%1] Reserved"](setName))
        self.reserved = setID
        self:RegisterEvent("PLAYER_REGEN_ENABLED", "ReservedJob")
        return false
    end

    local isCasting = UnitCastingInfo("player")
    local isChanneling = UnitChannelInfo("player")
    if isCasting or isChanneling then
        pw(L["[%1] Reserved"](setName))
        self.reserved = setID
        self:RegisterEvent("UNIT_SPELLCAST_STOP", "ReservedJob")
        self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "ReservedJob")
        return false
    end

    self.reserved = nil

    if isEquipped then
        p(L["[%1] Already equipped"](setName))
        self:RefreshUI(setName)
    else
        if missingItems > 0 then
            pe(L["[%1] %2 items missing"](setName, missingItems))
        end
        self.currentSet = setID
        C_EquipmentSet.UseEquipmentSet(setID)
    end
end

function GearUp:EquipSetByName(setName)
    local setID = C_EquipmentSet.GetEquipmentSetID(setName)
    if setID then
        self:EquipSet(setID)
    else
        pe(L["[%1] Doesn't exist"](setName))
    end
end

function GearUp:EquipmentCheck()
    for i = 0, GetNumEquipmentSets()-1 do
        local _, isEquipped = self:GetEquipmentSetInfo(i)
        if isEquipped then
            self.currentSet = i
            return i
        end
    end
    return nil
end

function GearUp:OnTalentChange(event, curr, prev)
    local talents, maxPoints = {}, 0
    local mainSpec
    for i = 1, GetNumTalentTabs() do
        local name, _, points = GetTalentTabInfo(i, _, _, curr)
        talents[i] = {
            name = name,
            points = points,
        }
        if points > maxPoints then
            mainSpec = name
            maxPoints = points
        end
    end
    if mainSpec then
        for i = 0, NUM_MAX_EQUIPMENT_SETS-1 do
            local name = self:GetEquipmentSetInfo(i)
            if name then
                local hit = string.match("@"..mainSpec:upper(), "^"..name:upper())
                if hit then
                    p(L["Talent changed [%1] (%2)"](mainSpec, maxPoints))
                    self:EquipSet(i)
                end
            end
        end
    end
end
