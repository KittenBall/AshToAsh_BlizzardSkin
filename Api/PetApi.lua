Scorpio "AshToAsh.BlizzardSkin.Api.Pet" ""

PetColor = {}

function AshBlzSkinApi.UnitIsPet()
    return Wow.Unit():Map(function(unit)
        return unit and unit:match("[pP][eE][tT]") and true or false
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetColor()
    return Wow.UnitOwner():Map(function(unit)
        local key = UnitClassBase(unit) or "GREEN"
        local color = PetColor[key]
        
        if not color then
            color = Color[key]
            local h, s, v = color:ToHSV()
            color = Color.FromHSV(h, s*0.85, v*0.85)
            PetColor[key] = color
        end

        return color
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