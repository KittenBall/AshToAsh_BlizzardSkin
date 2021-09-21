-- LibCustomGlow's Scorpio version, most of the code is copied from LibCustomGlow
-- Credit:doez, Stanzilla
if not Scorpio("Test"):ValidateVersion("1") then return end

Scorpio "SpaUI.Widget.GlowAnimation" "1"

namespace "SpaUI.Widget"

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
    print("GlowFramePool OnPush", frame:GetName())
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

    frame.info = {}
    frame:Hide()
    frame:ClearAllPoints()
end

function GlowTexturePool:OnInit(texture)
    print("GlowTexturePool OnInit", self.MaxSize)
    texture:SetDrawLayer("ARTWORK", 7)
end

function GlowTexturePool:OnPop(texture)
    print("GlowTexturePool OnPop", texture:GetName())
end

function GlowTexturePool:OnPush(texture)
    print("GlowTexturePool OnPush", texture:GetName())
    texture:Hide()
    texture:ClearAllPoints()
end

function AddOrSetGlow(self, glowContainer, key, color, textureNumber, paddingHorizontal, paddingVertical, texture, texCoord, desaturated, frameLevel)
    key = key or ""
    local frame = glowContainer[key]
    if not frame then
        frame = GlowFramePool()
        frame:SetParent(self)
        glowContainer[key] = frame
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

__Sealed__() struct "AutoCastGlowInfo" {
    { name = "ParticleGroupNumber", type = NaturalNumber,           default = 4 },
    { name = "PaddingHorizontal",   type = Number,                  default = 0 },
    { name = "PaddingVertical",     type = Number,                  default = 0 },
    { name = "Scale",               type = Number,                  default = 1 },
    { name = "Period",              type = Number,                  default = 8 },
    { name = "Color",               type = ColorType,               default = Color(0.95, 0.95, 0.32) },
    { name = "Key",                 type = String },
    { name = "FrameLevel",          type = NaturalNumber,           default = 8 },
    { name = "Stop",                type = Boolean,                 default = false }
}

AutoCastGlowTexture = [[Interface\Artifacts\Artifacts]]
AutoCastGlowTexCoords = RectType(0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625)
AutoCastGlowSizes = { 7, 6, 5, 4 }

function StopAutoCastGlow(self, key)
    print("StopAutoCastGlow", key or "nil")
    if self._AutoCastGlow then
        if key then
            local glow = self._AutoCastGlow[key]
            if glow then
                GlowFramePool(glow)
            end
        else
            for k, glow in pairs(self._AutoCastGlow) do
                print("StopAutoCastGlow", glow:GetName())
                GlowFramePool(glow)
                self._AutoCastGlow[k] = nil
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

    local textureIndex = 0;
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
            elseif position> self.info.rightlim then
                self.textures[textureIndex]:SetPoint("CENTER", self, "TOPRIGHT", 0, -position + self.info.rightlim)
            elseif position> self.info.height then
                self.textures[textureIndex]:SetPoint("CENTER", self, "TOPLEFT", position - self.info.height, 0)
            else
                self.textures[textureIndex]:SetPoint("CENTER", self, "BOTTOMLEFT", 0, position)
            end
        end
    end
end

function StartAutoCastGlow(self, info)
    print("StartAutoCastGlow")
    if not self._AutoCastGlow then
        self._AutoCastGlow = {}
    end
    
    local period = (info.Period > 0) and info.Period or 8
    local particleGroupNumber = (info.ParticleGroupNumber > 0) and info.ParticleGroupNumber or 4
    local textureNumber = particleGroupNumber * 4
    local frame = AddOrSetGlow(self, self._AutoCastGlow, info.Key, info.Color, textureNumber, info.PaddingHorizontal, info.PaddingVertical, AutoCastGlowTexture, AutoCastGlowTexCoords, true, info.FrameLevel)
    
    for k, size in pairs(AutoCastGlowSizes) do
        for i = 1, particleGroupNumber do
            frame.textures[i + particleGroupNumber * (k - 1)]:SetSize(size * info.Scale, size * info.Scale)
        end
    end

    frame.timer = frame.timer or {0,0,0,0}
    frame.info = frame.info or {}
    frame.info.particleGroupNumber = particleGroupNumber
    frame.info.period = period
    frame.OnUpdate = AutoCastGlowUpdate
end

UI.Property             {
    name                = "AutoCastGlow",
    require             = Frame,
    type                = AutoCastGlowInfo + Boolean,
    default             = nil,
    set                 = function(self, info)
        if type(info) == "boolean" then
            if info then
                StartAutoCastGlow(self, AutoCastGlowInfo())
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