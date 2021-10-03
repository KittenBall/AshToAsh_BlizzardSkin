Scorpio "AshToAsh.BlizzardSkin.Api.Pet" ""

PetOwnerClassMap = LruCache(100)

local function getUnitPetGUID(playerUnit, petUnit)
    if playerUnit and UnitIsPlayer(playerUnit) then
        if UnitExists(petUnit) then
            return UnitGUID(petUnit)
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
            petOwnerInfo.subGroup = subGroup
        else
            petOwnerInfo.subGroup = nil
        end
        PetOwnerClassMap[petGuid] = petOwnerInfo
    end
end

__SystemEvent__ "GROUP_ROSTER_UPDATE" "UNIT_NAME_UPDATE" "UNIT_PET" "UNIT_CONNECTION"
function UpdateGroupPetMap(unit)
    if unit and UnitExists(unit) then
        mapPetGuidToUnit(unit, getUnitPetGUID(unit, unit .. "pet"))
    elseif unit == nil then
        unit = "player"
        mapPetGuidToUnit(unit, getUnitPetGUID(unit, "pet"))

        if IsInGroup() then
            if IsInRaid() then
                for i = 1, 40 do
                    local playerUnit = "raid" .. i
                    if UnitExists(playerUnit) then
                        mapPetGuidToUnit(playerUnit, getUnitPetGUID(playerUnit, "raidpet"..i), UnitInRaid(playerUnit))
                    else
                        break
                    end
                end
            else
                for i = 1, 4 do
                    local playerUnit = "party"..i
                    if UnitExists(playerUnit) then
                        mapPetGuidToUnit(playerUnit, getUnitPetGUID(unplayerUnit, "partypet"..i))
                    else
                        break
                    end
                end
            end
        end
    end
end

PetColor = {}

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetColor()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
        if not unit then return end
        
        local guid = UnitGUID(unit)
        if guid then
            local petOwnerInfo = PetOwnerClassMap[guid]
            if petOwnerInfo and petOwnerInfo ~= -1 then
                local key = petOwnerInfo.class or "GREEN"
                local color = PetColor[key]

                if not color then
                    color = Color[key]
                    local h, s, v = color:ToHSV()
                    color = Color.FromHSV(h, s*0.85, v*0.85)
                    PetColor[key] = color
                end

                return color
            end
        end
        return Color[UnitClassBase(unit) or "GREEN"]
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetOwnerName()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
        if not unit then return end
        local guid = UnitGUID(unit)
        if guid then
            local petOwnerInfo = PetOwnerClassMap[guid]
            if petOwnerInfo and petOwnerInfo ~= -1 then
                local name
                if petOwnerInfo.name then
                    name = petOwnerInfo.name
                end
                if name and petOwnerInfo.subGroup then
                    name = name .. ("("..GROUP_NUMBER..")"):format(petOwnerInfo.subGroup)
                end
                if name then return name end
            end
        end
        
        local getTipLines = GetGameTooltipLines("Unit", unit)
        local _, left = getTipLines(_, 1)
        return left
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetInRange()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'"):ToSubject()):Map(function(unit)
        return UnitInRange(unit) or not IsInGroup()
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetThreatLevel()
    return Wow.FromUnitEvent("UNIT_THREAT_SITUATION_UPDATE"):Map(function(unit)
        return UnitExists(unit) and UnitThreatSituation(unit) or 0
    end)
end