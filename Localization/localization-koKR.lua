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
L["Description"] = [[Shift+드래그: 프레임 이동
 - 좌클릭: 갈아입기 / Shift+좌클릭: 해당 특성으로 변경
 - 우클릭: 현재 장비셋 갱신 / Ctrl+우클릭: 새로운 장비셋 생성
 - [@주특성]셋이 있으면 특성 변경 시 자동 장착됩니다.
 - 저장 시 속옷, 휘장은 무시합니다.]]
L["[%1] Already equipped"]  = function(setName) return "["..setName.."] 이미 장착 중" end
L["[%1] Equipped"]          = function(setName) return "["..setName.."] 장착 완료" end
L["[%1] Failed"]            = function(setName) return "["..setName.."] 장착 실패" end

L["[%1] Reserved"]          = function(setName) return "["..setName.."] 예약" end
L["[%1] %2 items missing"]  = function(setName, missingItems) return "["..setName.."] 장비 "..missingItems.."개 누락" end
L["[%1] Doesn't exist"]     = function(setName) return "["..setName.."] 없습니다" end

L["Create set"]             = "새로운 장비셋 생성"
L["Save [%1]"]              = function(setName) return "["..setName.."] 저장합니다" end
L["Spec changed {%1} (%2)"] = function(specName, points) return "특성 변경 감지 {"..specName.."} ("..points.." 포인트)" end
L["Switch Spec %1 {%2}"]    = function(specID, specName) return "Shift 클릭 시 "..specID.."번 특성 {"..specName.."} 변경" end

L["Floating UI resized to"] = function(width, height) return "UI 크기 변경 "..width.."x"..height end
L["/gconf Usage"]           = "/gconf 너비 높이  (기본값: 56 18)"
