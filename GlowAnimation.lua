-- LibCustomGlow's Scorpio version, most of the code is copied from LibCustomGlow
-- Credit:doez, Stanzilla
if not Scorpio("SpaUI.Widget.GlowAnimation"):ValidateVersion("1") then return end

Scorpio "SpaUI.Widget.GlowAnimation" "1"

namespace "SpaUI.Widget"

-------------------------------------------------
-- Pool
-------------------------------------------------

-- Glow Animation Pool
-- Just record the max size, and override the "New" function to create frame or texture
__Sealed__()
class "GlowAnimationRecycle"(function(_ENV)
    inherit "Recycle"

    property "MaxSize" {
        type            = Number,
        default         = 0
    }

    function New(self)
        self.MaxSize = self.MaxSize + 1
        return self.Type("SpaUI.Widget.GlowAnimation" .. self.Type .. self.MaxSize)
    end
end)

GlowFramePool = GlowAnimationRecycle(Frame)
GlowTexturePool = GlowAnimationRecycle(Texture)

function GlowFramePool:OnInit(frame)
    frame.textures = {}
end

function GlowFramePool:OnPush(frame)
    frame.OnHide = nil
    frame.key = nil
    frame.container = nil

    frame.OnUpdate = nil

    local parent = frame:GetParent()
    local name = frame:GetName()
    if parent[name] then
        parent[name] = nil
    end

    if frame.textures then
        for _, texture in pairs(frame.textures) do
            GlowTexturePool(texture)
        end
        wipe(frame.textures)
    end

    frame.timer = nil
    frame.info = {}
    frame:Hide()
    frame:ClearAllPoints()
end

function GlowTexturePool:OnInit(texture)
    texture:SetDrawLayer("ARTWORK", 7)
end

function GlowTexturePool:OnPush(texture)
    texture:Hide()
    texture:ClearAllPoints()
end

-------------------------------------------------
-- Add Glow
-------------------------------------------------

-- When glow target frame hide, auto recycle
local function autoRecycleOnHide(self)
    if self.key and self.container  then
        self.container[self.key] = nil
        self.key = nil
        self.container = nil
        GlowFramePool(self)
    end
end

-- Add glow to target frame, or set glow
function AddOrSetGlow(self, glowContainer, key, color, textureNumber, paddingHorizontal, paddingVertical, texture, texCoord, desaturated, frameLevel, recycleOnHide, alphaMode)
    key = key or ""
    local frame = glowContainer[key]
    if not frame then
        frame = GlowFramePool()
        frame:SetParent(self)
        glowContainer[key] = frame
    end

    if recycleOnHide then
        frame.key = key
        frame.container = glowContainer
        frame.OnHide = autoRecycleOnHide
    end

    frame:SetFrameLevel(self:GetFrameLevel() + frameLevel)
    frame:SetPoint("TOPLEFT", self, "TOPLEFT", -paddingHorizontal + 0.05, paddingVertical + 0.05)
    frame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", paddingHorizontal, -paddingVertical + 0.05)
    frame:Show()

    for i = 1, textureNumber do
        if not frame.textures[i] then
            frame.textures[i] = GlowTexturePool()
            frame.textures[i]:SetParent(frame)
        end
        frame.textures[i]:SetTexture(texture)
        frame.textures[i]:SetTexCoord(texCoord.left, texCoord.right, texCoord.top, texCoord.bottom)
        frame.textures[i]:SetDesaturated(desaturated)
        frame.textures[i]:SetVertexColor(color.r, color.g, color.b, color.a)
        if alphaMode then
            frame.textures[i]:SetBlendMode(alphaMode)
        end
        frame.textures[i]:Show()
    end

    while #frame.textures > textureNumber do
        GlowTexturePool(frame.textures[#frame.textures])
        table.remove(frame.textures)
    end

    return frame
end

-------------------------------------------------
-- AutoCastGlow
-------------------------------------------------

__Sealed__() struct "AutoCastGlowOption" {
    -- Corresponding to the N param of the LibCustomGlow.AutoCastGlow_Start
    -- Number of particle groups. Each group contains 4 particles
    { name = "ParticleGroupNumber", type = NaturalNumber,           default = 4 },
    -- Corresponding to the xoffset param of the LibCustomGlow.AutoCastGlow_Start
    -- Horizontal margin between glow and target frame
    { name = "PaddingHorizontal",   type = Number,                  default = 0 },
    -- Corresponding to the yoffset param of the LibCustomGlow.AutoCastGlow_Start
    -- Vertical margin between glow and target frame
    { name = "PaddingVertical",     type = Number,                  default = 0 },
    -- Scale of particles
    { name = "Scale",               type = Number,                  default = 1 },
    -- Corresponding to the frequency param of the LibCustomGlow.AutoCastGlow_Start
    { name = "Period",              type = Number,                  default = 8 },
    -- AutoCastGlow color
    { name = "Color",               type = ColorType,               default = Color(0.95, 0.95, 0.32) },
    -- Key of glow, allows for multiple glows on one frame
    { name = "Key",                 type = String },
    -- FrameLevel of glow
    { name = "FrameLevel",          type = NaturalNumber,           default = 8 },
    -- Whether recycle on glow hide
    { name = "recycleOnHide",       type = Boolean,                 default = true },
    -- Start or stop glow
    { name = "Stop",                type = Boolean,                 default = false }
}

do
    DefaultAutoCastGlowOPtion       = AutoCastGlowOption()
    AutoCastGlowTexture             = Scorpio.IsRetail and [[Interface\Artifacts\Artifacts]] or [[Interface\ItemSocketingFrame\UI-ItemSockets]]
    AutoCastGlowTexCoords           = Scorpio.IsRetail and RectType(0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625) or RectType(0.3984375, 0.4453125, 0.40234375, 0.44921875)
    AutoCastGlowAlphaMode           = Scorpio.IsRetail and nil or "ADD"
    AutoCastGlowSizes               = { 7, 6, 5, 4 }

    function StopAutoCastGlow(self, key)
        if self._AutoCastGlow then
            if key then
                local glow = self._AutoCastGlow[key]
                if glow then
                    self._AutoCastGlow[key] = nil
                    GlowFramePool(glow)
                end
            else
                for k, glow in pairs(self._AutoCastGlow) do
                    self._AutoCastGlow[k] = nil
                    GlowFramePool(glow)
                end
            end
        end
    end

    local function AutoCastGlowUpdate(self, elapsed)
        local width, height = self:GetSize()
        if width ~= self.info.width or height ~= self.info.height then
            self.info.width = width
            self.info.height = height
            self.info.perimeter = 2 * (width + height)
            self.info.bottomlim = height * 2 + width
            self.info.rightlim = height + width
            self.info.space = self.info.perimeter /self.info.particleGroupNumber
        end

        local textureIndex = 0
        for k = 1, 4 do
            self.timer[k] = self.timer[k] + elapsed / (self.info.period * k)
            if self.timer[k] > 1 or self.timer[k] < -1 then
                self.timer[k] = self.timer[k] % 1
            end
            for i = 1, self.info.particleGroupNumber do
                textureIndex = textureIndex+1
                local position = (self.info.space * i + self.info.perimeter * self.timer[k]) % self.info.perimeter
                if position > self.info.bottomlim then
                    self.textures[textureIndex]:SetPoint("CENTER", self, "BOTTOMRIGHT", -position + self.info.bottomlim, 0)
                elseif position > self.info.rightlim then
                    self.textures[textureIndex]:SetPoint("CENTER", self, "TOPRIGHT", 0, -position + self.info.rightlim)
                elseif position > self.info.height then
                    self.textures[textureIndex]:SetPoint("CENTER", self, "TOPLEFT", position - self.info.height, 0)
                else
                    self.textures[textureIndex]:SetPoint("CENTER", self, "BOTTOMLEFT", 0, position)
                end
            end
        end
    end

    function StartAutoCastGlow(self, option)
        if not self:IsVisible() then return end
        if not self._AutoCastGlow then
            self._AutoCastGlow = {}
        end

        local period = (option.Period ~= 0) and option.Period or 8
        local particleGroupNumber = (option.ParticleGroupNumber > 0) and option.ParticleGroupNumber or 4
        local textureNumber = particleGroupNumber * 4
        local frame = AddOrSetGlow(self, self._AutoCastGlow, option.Key, option.Color, textureNumber, option.PaddingHorizontal, option.PaddingVertical, AutoCastGlowTexture, AutoCastGlowTexCoords, true, option.FrameLevel, option.recycleOnHide, AutoCastGlowAlphaMode)

        for k, size in pairs(AutoCastGlowSizes) do
            for i = 1, particleGroupNumber do
                frame.textures[i + particleGroupNumber * (k - 1)]:SetSize(size * option.Scale, size * option.Scale)
            end
        end

        frame.timer = frame.timer or { 0, 0, 0, 0 }
        frame.info = frame.info or {}
        frame.info.particleGroupNumber = particleGroupNumber
        frame.info.period = period
        frame.OnUpdate = AutoCastGlowUpdate
    end

    -- Show or hide AutoCastGlow ainimation on frame
    UI.Property             {
        name                = "AutoCastGlow",
        require             = Frame,
        type                = AutoCastGlowOption + Boolean,
        default             = nil,
        set                 = function(self, info)
            if type(info) == "boolean" then
                if info then
                    StartAutoCastGlow(self, DefaultAutoCastGlowOPtion)
                else
                    StopAutoCastGlow(self)
                end
            else
                if not info or info.Stop then
                    StopAutoCastGlow(self, info.Key)
                else
                    StartAutoCastGlow(self, info)
                end
            end
        end
    }
end