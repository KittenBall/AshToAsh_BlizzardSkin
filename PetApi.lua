Scorpio "AshToAsh.BlizzardSkin.Api.Pet" ""

PetOwnerClassMap = LruCache(100)

local function getUnitPetGUID(unit)
    if unit and UnitIsPlayer(unit) then
        unit = unit.."pet"
        if UnitExists(unit) then
            return UnitGUID(unit)
        end
    end
end

local function mapPetGuidToUnit(unit, petGuid, raidIndex)
    if petGuid then
        local petOwnerInfo = PetOwnerClassMap[petGuid]
        if not petOwnerInfo or petOwnerInfo == -1 then
            petOwnerInfo = {}
        end
        petOwnerInfo.class = UnitClassBase(unit)
        petOwnerInfo.name = UnitName(unit)
        if raidIndex then
            local _, _, subGroup = GetRaidRosterInfo(raidIndex)
            petOwnerInfo.subGroup = subGroup or nil
        else
            petOwnerInfo.subGroup = nil
        end
        PetOwnerClassMap[petGuid] = petOwnerInfo
    end
end

__SystemEvent__ "GROUP_ROSTER_UPDATE" "UNIT_NAME_UPDATE" "UNIT_PET" "UNIT_CONNECTION"
function UpdateGroupPetMap(unit)
    if unit and UnitExists(unit) then
        mapPetGuidToUnit(unit, getUnitPetGUID(unit))
    elseif unit == nil then
        unit = "player"
        mapPetGuidToUnit(unit, getUnitPetGUID(unit))

        if IsInGroup() then
            if IsInRaid() then
                for i = 1, 39 do
                    unit = "raid"..i
                    if UnitExists(unit) then
                        mapPetGuidToUnit(unit, getUnitPetGUID(unit), UnitInRaid(unit))
                    else
                        break
                    end
                end
            else
                for i = 1, 4 do
                    unit = "party"..i
                    if UnitExists(unit) then
                        mapPetGuidToUnit(unit, getUnitPetGUID(unit))
                    else
                        break
                    end
                end
            end
        end
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetColor()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
        if not unit then return end
        
        local guid = UnitGUID(unit)
        if guid then
            local petOwnerInfo = PetOwnerClassMap[guid]
            if petOwnerInfo and petOwnerInfo ~= -1 then
                local h, s, v = Color[petOwnerInfo.class or "GREEN"]:ToHSV()
                return Color.FromHSV(h, s*0.85, v*0.85)
            end
        end
        return Color[UnitClassBase(unit) or "GREEN"]
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetName()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
        if not unit then return end
        
        local guid = UnitGUID(unit)
        if guid then
            local petOwnerInfo = PetOwnerClassMap[guid]
            if petOwnerInfo and petOwnerInfo ~= -1 and petOwnerInfo.subGroup then
                return ("%s("..GROUP_NUMBER..")"):format(UnitName(unit), petOwnerInfo.subGroup)
            end
        end
        return UnitName(unit)
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetOwnerName()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
        if not unit then return end
        local guid = UnitGUID(unit)
        if guid then
            local petOwnerInfo = PetOwnerClassMap[guid]
            if petOwnerInfo and petOwnerInfo ~= -1 and petOwnerInfo.name then
                return petOwnerInfo.name
            end
        end
        local getTipLines = GetGameTooltipLines("Unit", unit)
        local _, left = getTipLines(_, 1)
        return left
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetInRange()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'")):Map(function(unit)
        return UnitInRange(unit) or not IsInGroup()
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetThreatLevel()
    return Wow.FromUnitEvent("UNIT_THREAT_SITUATION_UPDATE"):Map(function(unit)
        return UnitExists(unit) and UnitThreatSituation(unit) or 0
    end)
end