local AddonName = ...

local L = LibStub('AceLocale-3.0'):NewLocale(AddonName, "koKR")
if not L then return end

-- Header for printed message
L["GearUpInfo"] = "|cff10f010■ GearUp|r - "
L["GearUpWarn"] = "|cfff0f010■ GearUp|r - "
L["GearUpErr"]  = "|cfff01010■ GearUp|r - "

-- Dropdown Menu
L["In combat"] = "전투 중"

-- Messages
L["Description"] = "장비셋 생성/삭제는 장비관리창에서 해 주세요\n - Shift+드래그: 프레임 이동\n - 좌클릭: 갈아입기\n - 우클릭: 장비셋 저장(속옷, 휘장 무시)"
L["[%1] Already equipped"]  = function(setName) return "["..setName.."] 이미 장착 중" end
L["[%1] Equipped"]          = function(setName) return "["..setName.."] 장착 완료" end
L["[%1] Failed"]            = function(setName) return "["..setName.."] 장착 실패" end

L["[%1] Reserved"]          = function(setName) return "["..setName.."] 예약" end
L["[%1] %2 items missing"]  = function(setName, missingItems) return "["..setName.."] 장비 "..missingItems.."개 누락" end
L["[%1] Doesn't exist"]     = function(setName) return "["..setName.."] 없습니다" end

L["Save [%1]"]              = function(setName) return "["..setName.."] 저장합니다" end
L["Talent changed [%1] (%2)"] = function(specName, points) return "특성 변경 ["..specName.."] ("..points.." 포인트)" end
