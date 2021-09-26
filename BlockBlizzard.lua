Scorpio "AshToAsh.BlizzardSkin.BlockBlizzard" ""

local hiddenFrame = Frame("BlockBlizzard")
hiddenFrame:Hide()

-- 不替换RegisterEvent，使用这种方式防止taint
local function clearEvents(frame, event)
    frame:UnregisterAllEvents()
end

local function clearScript(frame, scriptType, handler)
    if handler then
        frame:SetScript(scriptType, nil)
    end
end

local function clearFrame(frame)
    hooksecurefunc(frame, "RegisterEvent", clearEvents)
    hooksecurefunc(frame, "RegisterUnitEvent", clearEvents)
    hooksecurefunc(frame, "RegisterAllEvents", clearEvents)
    hooksecurefunc(frame, "SetScript", clearScript)
    
    frame:SetScript("OnEvent", nil)
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEnter", nil)
    frame:SetScript("OnLeave", nil)
    if frame:HasScript("OnClick") then
        frame:SetScript("OnClick", nil)
    end
    frame:UnregisterAllEvents()
end

local function BlockBlizzardFrames(frame)
    if frame and frame:IsObjectType("Frame") then
        local children = { frame:GetChildren() }
        for _, child in ipairs(children) do
           BlockBlizzardFrames(child)
        end

        clearFrame(frame)
    end
end

function OnLoad()
    _Enabled = DB.BlockBlizzardUnitFrames
end

__Async__()
function OnEnable()
    if CompactPartyFrame then
        BlockUnitFrames(CompactPartyFrame)
    end

    if not IsAddOnLoaded('Blizzard_CompactRaidFrames') then
        while NextEvent('ADDON_LOADED') ~= 'Blizzard_CompactRaidFrames' do end
    end

    BlockUnitFrames(CompactRaidFrameContainer)
end

__NoCombat__()
function BlockUnitFrames(frame)
    frame:SetParent(hiddenFrame)
    BlockBlizzardFrames(frame)
end

__SecureHook__()
function CompactUnitFrame_OnLoad(frame)
    local name = frame:GetName()
    if name and (name:find("CompactRaid") or name:find("CompactParty")) then
        BlockBlizzardFrames(frame)
    end
end

__SecureHook__()
__NoCombat__()
function CompactPartyFrame_Generate()
    CompactPartyFrame:SetParent(hiddenFrame)
    BlockBlizzardFrames(CompactPartyFrame)
end