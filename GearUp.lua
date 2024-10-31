local addonName, _ = ... 
GearUp = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
GearUp.name = addonName
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
GearUp.version = GetAddOnMetadata(addonName, "Version")

local L = LibStub("AceLocale-3.0"):GetLocale(GearUp.name, true)

local NUM_MAX_EQUIPMENT_SETS = 10

-- Local func
local function p(msg, ...) print(L["GearUpInfo"]..msg, ...) end
local function pw(msg, ...) print(L["GearUpWarn"]..msg, ...) end
local function pe(msg, ...) print(L["GearUpErr"]..msg, ...) end
local InCombatLockdown = InCombatLockdown

StaticPopupDialogs["GEARUP_SAVE_EQUIPMENTSET"] = {
    text = "%s",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function() GearUp:SaveEquipSet() end,
    enterClicksFirstButton = true,
    hideOnEscape = true,
}

StaticPopupDialogs["GEARUP_CREATE_EQUIPMENTSET"] = {
    text = L["Create set"],
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 12,
    OnAccept = function(self)
        local setName = self.editBox:GetText()
        if setName ~= "" then GearUp:CreateEquipSet(setName) end
    end,
    EditBoxOnEnterPressed = function(editBox)
        local setName = editBox:GetText()
        if setName ~= "" then GearUp:CreateEquipSet(setName) end
        editBox:GetParent():Hide()
    end,
    OnHide = function(self) self.editBox:SetText("") end,
    EditBoxOnEscapePressed = function(editBox) editBox:GetParent():Hide() end,
    --enterClicksFirstButton = true,
}

SLASH_GEARUP1 = "/geq"
SlashCmdList["GEARUP"] = function(msg)
    GearUp:EquipSetByName(msg)
end

SLASH_GEARUPCONFIG1 = "/gconf"
SlashCmdList["GEARUPCONFIG"] = function(msg)
    local width, height = msg:match("(%d+)%s+(%d+)")
    width, height = tonumber(width), tonumber(height)
    if width and height then
        GearUp.ui:SetWidth(width)
        GearUp.ui:SetHeight(height)
        p(L["Floating UI resized to"](width, height))
    else
        pw(L["/gconf Usage"])
    end
end

function GearUp:OnInitialize()
    self:InitUI()
    self:HookSaveFunc()
    self:EnableItemPopupButton()

    -- Equipment check
    self.ticker = C_Timer.NewTicker(3, function()
        if C_EquipmentSet.GetNumEquipmentSets() > 0 then   -- Early call returns 0
            self.ticker:Cancel()
        end
        self:OnEquipSetChange()
    end, 5)
end

function GearUp:InitUI()
    local ui = CreateFrame("Button", self.name.."FloatingUI", UIParent, "BackdropTemplate")
    self.ui = ui
    ui:EnableMouse(true)
    ui:SetMovable(true)
    ui:SetResizable(true)
    -- User resized override below width, height
    ui:SetWidth(56)
    ui:SetHeight(18)
    ui:SetBackdrop({
        bgFile = "Interface/TutorialFrame/TutorialFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    ui:SetBackdropBorderColor(1, 1, 1, 0.3)
    ui:SetPoint("CENTER")

    ui.text = ui:CreateFontString()
    ui.text:SetAllPoints()
    ui.text:SetFontObject("GameFontNormal")
    ui.text:SetText("|cff10f010GearUp|r ")
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
        elseif btn == "RightButton" and not InCombatLockdown() then
            if IsControlKeyDown() then
                StaticPopup_Show("GEARUP_CREATE_EQUIPMENTSET")
            elseif GearUp.currentSet then
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

function GearUp:HookSaveFunc()
    self.originalSaveFunc = C_EquipmentSet.SaveEquipmentSet
    C_EquipmentSet.SaveEquipmentSet = function(setID, icon)
        C_EquipmentSet.IgnoreSlotForSave(INVSLOT_BODY)
        C_EquipmentSet.IgnoreSlotForSave(INVSLOT_TABARD)
        self.originalSaveFunc(setID, icon)
        p(L["Save [%1]"](self:GetEquipmentSetInfo(setID)))
    end
    self.originalCreateFunc = C_EquipmentSet.CreateEquipmentSet
    C_EquipmentSet.CreateEquipmentSet = function(setName, icon)
        self.originalCreateFunc(setName, icon or GetInventoryItemTexture("player", INVSLOT_NECK))
        -- IgnoreSlotForSave doesn't affect CreateEquipmentSet, so save again
        self.currentSet = C_EquipmentSet.GetEquipmentSetID(setName)
        C_EquipmentSet.SaveEquipmentSet(self.currentSet, icon)
        --self:SaveEquipSet()
    end
end

function GearUp:EnableItemPopupButton()
    -- Inspired by addon 'Enable Equipment Select'
    EquipmentFlyoutPopoutButton_HideAll = function() end -- Do nothing
    EquipmentFlyoutPopoutButton_ShowAll()
end

function GearUp:GetEquipmentSetInfo(setID, colorize)
--  name, iconFileID, setID, isEquipped, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID)
    if setID then
        local name, _, _, isEquipped, numItems, numEquipped, numInInventory, numLost = C_EquipmentSet.GetEquipmentSetInfo(setID)
        if colorize and name then
            if numLost > 0 then
                name = "|cffe55451"..name.."|r"
            --elseif (numItems - numEquipped) > 0 and (numItems - numEquipped) < 3 then
            --    name = "|cfff0f010"..name.."|r"
            end
        end
        return name, isEquipped, numLost, numItems, numEquipped
    end
end

local function IsSelected(value)
    local setID = value[1]
    if setID ~= -1 then
        local _, isEquipped = GearUp:GetEquipmentSetInfo(setID, nil)
        return isEquipped
    end
    return false
end
local function OnSelect(value)
    local setID, specID = value[1], value[2]
    if IsShiftKeyDown() and specID then
        -- Change Spec
        SetActiveTalentGroup(specID)
    else
        GearUp:EquipSet(setID)
    end
end
local function Initializer(tooltipText, button, desc, _)
    if tooltipText then
        desc:SetTooltip(function(tooltip, _)
            GameTooltip_AddNormalLine(tooltip, tooltipText)
        end)
    end
    button:SetScale(0.9)
end
local function DropdownGenerator(owner, rootDescription)
    if InCombatLockdown() then
        local radio = rootDescription:CreateRadio("|cffe55451"..L["In combat"].."|r", IsSelected, OnSelect, {-1})
        radio:AddInitializer(function(...) return Initializer(nil, ...) end)
    end

    local specs = {}
    for i = 1, GetNumTalentGroups() do
        specs[i] = GearUp:GetMainSpec(i)
    end

    for i = 0, NUM_MAX_EQUIPMENT_SETS-1 do
        local name = GearUp:GetEquipmentSetInfo(i, true)
        if name then
            local specID, tooltipText
            for j = 1, GetNumTalentGroups() do
                if specs[j] then
                    if string.match("@"..specs[j]:upper(), "^"..name:upper()) or string.match("@"..j, "^"..name:sub(1,2)) then
                        tooltipText = L["Switch Spec %1 {%2}"](j, specs[j])
                        specID = j
                        break
                    end
                end
            end
            local radio = rootDescription:CreateRadio(name:gsub("@","|cff666666@|r"), IsSelected, OnSelect, {i, specID})
            radio:AddInitializer(function(...) return Initializer(tooltipText, ...) end)
        end
    end
end

function GearUp:DropMenu()
    MenuUtil.CreateContextMenu(self.ui, DropdownGenerator)
end

function GearUp:CreateEquipSet(setName)
    if setName then  -- Default is Neck icon
        C_EquipmentSet.CreateEquipmentSet(setName, GetInventoryItemTexture("player", INVSLOT_NECK))
    end
end

function GearUp:SaveEquipSet()
    if self.currentSet then
        C_EquipmentSet.SaveEquipmentSet(self.currentSet)
    end
end

function GearUp:OnEnable()
    -- Register events
    self:RegisterEvent("EQUIPMENT_SETS_CHANGED", "OnEquipSetChange")
    self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", "OnSwapFinish")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "OnSpecChange")
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
        self.currentSet = setID
    else
        pe(L["[%1] Failed"](setName))
    end
    SpellBookFrame_PlayOpenSound()
end

function GearUp:OnEquipSetChange()
    if C_EquipmentSet.GetNumEquipmentSets() > 0 then
        self.ui:Show()
    else
        self.ui:Hide()
    end
    self:RefreshUI(self:GetEquipmentSetInfo(self:EquipmentCheck(), true))
end

function GearUp:RefreshUI(text)
    if text then
        -- Blur '@'
        self.ui.text:SetText("|cffcccccc"..text:gsub("@","|cff666666@|r").."|r")
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
    local setName, isEquipped, numLost, numItems, numEquipped  = self:GetEquipmentSetInfo(setID, true)

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

    if isEquipped and (numItems == numEquipped) then
        p(L["[%1] Already equipped"](setName))
        self:RefreshUI(setName)
    else
        if numLost > 0 then
            pe(L["[%1] %2 items missing"](setName, numLost))
        end
        --self.currentSet = setID
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
    local guessID
    local guessMissing = 3
    for i = 0, NUM_MAX_EQUIPMENT_SETS-1 do
        local _, isEquipped, numLost, numItems, numEquipped = self:GetEquipmentSetInfo(i)
        if isEquipped then
            self.currentSet = i
            return i
        else
            -- If 1 or 2 items have changed but not saved, check it
            if numItems and numEquipped and numItems > 10 then
                local numUnequipped = numItems - numEquipped
                if numUnequipped < guessMissing then
                    guessID = i
                    guessMissing = numUnequipped
                end
            end
        end
    end
    self.currentSet = guessID
    return guessID
end

function GearUp:OnSpecChange(event, curr, prev)
    local mainSpec, points = self:GetMainSpec(curr)
    if mainSpec then
        for i = 0, NUM_MAX_EQUIPMENT_SETS-1 do
            local name = self:GetEquipmentSetInfo(i)
            if name and string.match("@"..mainSpec:upper(), "^"..name:upper()) then
                p(L["Spec changed {%1} (%2)"](mainSpec, points))
                self:EquipSet(i)
            elseif name and  string.match("@"..curr, "^"..name:sub(1,2)) then
                p(L["Spec changed {%1} (%2)"](mainSpec.."("..curr..")", points))
                self:EquipSet(i)
            end
        end
    end
end

function GearUp:GetMainSpec(specGroup)
    local specs, maxPoints = {}, 0
    local mainSpec
    for tabOrder = 1, GetNumTalentTabs() do
        local _, name, _, _, points = GetTalentTabInfo(tabOrder, _, _, specGroup)
        specs[tabOrder] = {
            name = name,
            points = points,
        }
        if points > maxPoints then
            mainSpec = name
            maxPoints = points
        end
    end
    return mainSpec, maxPoints
end
