Scorpio "AshToAsh.BlizzardSkin.BlockBlizzard" ""

-- 不替换RegisterEvent，使用这种方式防止taint
local function clearEvents(frame, event)
    print("ClearEvents", frame:GetName(), event)
    frame:UnregisterAllEvents()
end

local function clearScript(frame, scriptType, handler)
    print("ClearScript", frame:GetName(), scriptType, handler)
    if handler then
        frame:SetScript(scriptType, nil)
    end
end

local function clearFrame(frame)
    print("ClearFrame", frame:GetName())
    hooksecurefunc(frame, "RegisterEvent", clearEvents)
    hooksecurefunc(frame, "RegisterUnitEvent", clearEvents)
    hooksecurefunc(frame, "RegisterAllEvents", clearEvents)
    hooksecurefunc(frame, "SetScript", clearScript)
    
    frame:SetScript("OnEvent", nil)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEnter", nil)
    frame:SetScript("OnLeave", nil)
    frame:SetScript("OnClick", nil)
    frame:UnregisterAllEvents()
    frame:Hide()
end

local function HideBlizzardFrames(frame)
    if frame and frame:IsObjectType("Frame") then
        local children = { frame:GetChildren() }
        for _, child in ipairs(children) do
           HideBlizzardFrames(child)
        end

        clearFrame(frame)
    end
end

function OnLoad()
    _Enabled = DB.BlockBlizzardUnitFrames
end

__Async__()
function OnEnable()
    BlockPartyFrames()
end

__NoCombat__()
function BlockPartyFrames()
    HideBlizzardFrames(CompactPartyFrame)
end

__NoCombat__()
__AddonSecureHook__('Blizzard_CompactRaidFrames', 'CompactRaidFrameContainer_OnLoad')
function BlockRaidFrames(frame)
    HideBlizzardFrames(frame)
end

__SecureHook__()
function CompactUnitFrame_OnLoad(frame)
    HideBlizzardFrames(frame)
end