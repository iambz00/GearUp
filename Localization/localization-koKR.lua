--[[ global vars & metadata ]]--
local AddonName = ...
local L = LibStub('AceLocale-3.0'):NewLocale(AddonName, "koKR")
if not L then return end

-- Header for printed message
L["GearUp"] = "|cff10f010GearUp|r - "	-- Font color start w/ |cAARRGGBB(Alpha,R,G,B), end w/ |r
L["GearUpErr"] = "|cfff01010GearUp|r - "

-- Messages
L["Auto swap ON"] = "장비 자동 교체 켜짐"
L["Auto swap OFF"] = "장비 자동 교체 |cfff01010꺼짐|r"

L["Already wearing [%1] set"] = function(setname) return "이미 ["..setname.."] 셋을 입고 있습니다" end
L["Equip [%1] set"] = function(setname) return "["..setname.."] 셋을 장착합니다." end
L["[%1] set equipped]"] = function(setname) return "["..setname.."] 셋 장착 완료" end
L["Failed to equip [%1] set. Check UI error message"] = function(setname) return "["..setname.."] 셋 장착 실패. 기본 에러 메시지를 확인하세요" end

L["Alt pressed! "] = "Alt 키 감지! "
L["Ctrl pressed! "] = "Ctrl 키 감지! "
L["Shift pressed! "] = "Shift 키 감지! "

L["IN COMBAT. Try after combat ends"] = "전투 중. 전투 종료 후 다시 시도하세요"
L["Set [%1] doesn't exist"] = function(setname) return "["..setname.."] 장비 셋이 없습니다" end
L["%1 items missing in [%2] set"] = function(missingItems, setname) return "["..setname.."] 셋에 장비가"..missingItems.."개 누락되었습니다" end

-- UI Message
L["Open Setting"] = "설정하기"
L["ANCHOR_TOOLTIP"] = "|cff9090f0드래그|r해서 이동합니다\n|cff9090f0우클릭|r으로 앵커를 숨깁니다\n인터페이스 옵션에서 다시 보이게 할 수 있습니다"

-- Options Dialog
L["General"] = "설정"
L["Profiles"] = "프로필"

L["Header 1"] = "장비 교체"
L["Description 1"] = "변경된 전문화와 이름이 같은 장비 셋으로 갈아입습니다.\n전문화 변경 시 Alt, Ctrl, Shift키를 눌러 다른 장비를 장착할 수도 있습니다.\nex> Alt - [전문화@] / Ctrl - [전문화^] / Shift - [전문화#]"

L["Header 2"] = "UI 및 위치"

L["Header 3"] = "단축키"
L["Description 3"] = "단축키 설정 메뉴에서 단축키를 지정할 수 있습니다"

L["Auto swap on Spec change"] = "특성 변경시 장비 자동 교체"
L["Show Floating UI"] = "별도 UI 표시"
L["Show Floating UI - DESC"] = "현재 장비를 표시하고 교체합니다"
L["Set UI movable"] = "UI 이동 가능"
L["Set UI movable - DESC"] = "앵커를 다시 표시합니다"
L["Reset UI position"] = "UI 위치 리셋"
L["Reset UI position - DESC"] = "화면 가운데로 옮깁니다"

L["Equipment set %1"] = function(num) return "장비 셋 "..num end
L["Not assigned"] = "|cfff0f010(지정 안됨)|r"

-- Bind header
L["Equip set 1"] = "장비 셋 1 장착"
L["Equip set 2"] = "장비 셋 2 장착"
L["Equip set 3"] = "장비 셋 3 장착"
L["Equip set 4"] = "장비 셋 4 장착"
L["Equip set 5"] = "장비 셋 5 장착"
L["Equip set 6"] = "장비 셋 6 장착"
L["Equip set 7"] = "장비 셋 7 장착"
L["Equip set 8"] = "장비 셋 8 장착"
L["Equip set 9"] = "장비 셋 9 장착"
L["Equip set 10"] ="장비 셋 10 장착"
