-- LibCustomGlow's Scorpio version, most of the code is copied from LibCustomGlow
-- Credit:doez, Stanzilla
if not Scorpio("SpaUI.Widget.GlowAnimation"):ValidateVersion("1") then return end

Scorpio "SpaUI.Widget.GlowAnimation" "1"

namespace "SpaUI.Widget"

__Sealed__()
interface "GlowAnimation"(function(_ENV)

    -------------------------------------------------
    -- Texture pool
    -------------------------------------------------

    local texturePool                   = Recycle(Texture, "GlowAnimationTexture%d")

    function texturePool:OnPush(texture)
        local maskNumber = texture:GetNumMaskTextures()
        for i = maskNumber, 1 do
            texture:RemoveMaskTexture(texture:GetMaskTexture(i))
        end

        texture:ClearAllPoints()
        texture:Hide()
    end

    function texturePool:OnInit(texture)
        texture:SetDrawLayer("ARTWORK", 6)
    end

    -------------------------------------------------
    -- Masktexture pool
    -------------------------------------------------

    local maskPool                      = Recycle(MaskTexture, "GlowAnimationMaskTexture%d")

    function maskPool:OnPush(mask)
        mask:ClearAllPoints()
        mask:Hide()
    end

    -------------------------------------------------
    -- Functions
    -------------------------------------------------    
    function AcquireTexture(self)
        return texturePool()
    end

    function ReleaseTexture(self, texture)
        return texturePool(texture)
    end

    function AcquireMaskTexture(self)
        return maskPool()
    end

    function ReleaseMaskTexture(self, mask)
        return maskPool(mask)
    end

end)

-------------------------------------------------
-- AutoCastGlow
-------------------------------------------------

__Sealed__()
__ChildProperty__(Frame, "AutoCastGlow")
__ChildProperty__(Frame, "AutoCastGlow1")
__ChildProperty__(Frame, "AutoCastGlow2")
__ChildProperty__(Frame, "AutoCastGlow3")
class "AutoCastGlow"(function(_ENV)
    inherit "Frame"
    extend "GlowAnimation"

    __Static__()
    property "GlowSizes"     { set = false, default = { 7, 6, 5, 4 } }

    local function UpdateFrameLevel(self)
        local parent = self:GetParent()
        if parent then
            self:SetFrameLevel(parent:GetFrameLevel() + self.FrameLevel)
        end
    end

    local function UpdateSizes(self)
        local groupNumber = self._GroupNumber or 4
        local scale = self.Scale
        for k, size in pairs(AutoCastGlow.GlowSizes) do
            for i = 1, groupNumber do
                local texture = self.textures[i + groupNumber * (k -1)]
                if texture then
                    texture:SetSize(size * scale, size * scale)
                end
            end
        end
    end

    local function UpdatePoints(self)
        local parent = self:GetParent()
        if parent then
            self:SetPoint("TOPLEFT", parent, "TOPLEFT", -self.PaddingHorizontal - 0.05, self.PaddingVertical + 0.05)
            self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", self.PaddingHorizontal + 0.05, -self.PaddingVertical - 0.05)
        end
    end

    local function AddOrRemoveTextures(self)
        local textureNumber = self.GroupNumber * 4
        for i = 1, textureNumber do
            local texture = self.textures[i]
            if not texture then
                texture = self:AcquireTexture()
                texture:SetParent(self)
                self.textures[i] = texture
            end
            texture:SetTexture(self.File)
            local texCoords = self.TexCoords
            texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
            texture:SetDesaturated(self.Desaturated)
            local color = self.Color
            texture:SetVertexColor(color.r, color.g, color.b, color.a)
            texture:SetBlendMode(self.AlphaMode)
            texture:Show()
        end
    
        while #self.textures > textureNumber do
            self:ReleaseTexture(self.textures[#self.textures])
            table.remove(self.textures)
        end
    end

    -- Corresponding to the N param of the LibCustomGlow.AutoCastGlow_Start
    -- Number of particle groups. Each group contains 4 particles
    property "GroupNumber"          {
        type        = NaturalNumber,
        default     = 4,
        get         = function(self) return self._GroupNumber or 4 end,
        set         = function(self, groupNumber)
            groupNumber = groupNumber >= 0 and groupNumber or 4
            self._GroupNumber = groupNumber
            AddOrRemoveTextures(self)
            UpdateSizes(self)
        end
    }

    -- Corresponding to the xoffset param of the LibCustomGlow.AutoCastGlow_Start
    -- Horizontal margin between glow and target frame
    property "PaddingHorizontal"    {
        type        = Number,
        default     = 0,
        get         = function(self) return self._PaddingHorizontal or 0 end,
        set         = function(self, paddingHorizontal)
            self._PaddingHorizontal = paddingHorizontal
            UpdatePoints(self)
        end
    }

    -- Corresponding to the yoffset param of the LibCustomGlow.AutoCastGlow_Start
    -- Vertical margin between glow and target frame
    property "PaddingVertical"      {
        type        = Number,
        default     = 0,
        get         = function(self) return self._PaddingVertical or 0 end,
        set         = function(self, paddingVertical)
            self._PaddingVertical = paddingVertical
            UpdatePoints(self)
        end
    }

    -- Scale of particles
    property "Scale"                {
        type        = Number,
        default     = 1,
        get         = function(self) return self._Scale or 1 end,
        set         = function(self, scale)
            scale = (scale >= 0) and scale or 1
            self._Scale = scale
            UpdateSizes(self)
        end
    }

    -- Corresponding to the frequency param of the LibCustomGlow.AutoCastGlow_Start
    -- Set to negative to inverse direction of rotation
    property "Period"               {
        type        = Number,
        default     = 8,
        get         = function(self) return self._Period or 8 end,
        set         = function(self, period)
            period = (period == 0) and 8 or period
            self._Period = period
        end
    }
    
    -- Whether glow texture is desaturated
    property "Desaturated"          {
        type        = Boolean,
        default     = true,
        get         = function(self) return self._Desaturated end,
        set         = function(self, desaturated)
            self._Desaturated = desaturated
            for _, texture in ipairs(self.textures) do
                texture:SetDesaturated(desaturated)
            end
        end
    }

    -- Glow color
    property "Color"                {
        type        = ColorType,
        default     = Color(0.95, 0.95, 0.32),
        get         = function(self) return self._Color or Color(0.95, 0.95, 0.32) end,
        set         = function(self, color)
            self._Color = color
            for _, texture in ipairs(self.textures) do
                texture:SetVertexColor(color.r, color.g, color.b, color.a)
            end
        end
    }

    -- FrameLevel of glow
    property "FrameLevel"           {
        type        = NaturalNumber,
        default     = 8,
        get         = function(self) return self._FrameLevel or 8 end,
        set         = function(self, frameLevel)
            self._FrameLevel = frameLevel
            UpdateFrameLevel(self)
        end
    }

    -- Texture file or fileID of particle
    property "File"                 {
        type        = String + Number,
        default     = Scorpio.IsRetail and [[Interface\Artifacts\Artifacts]] or [[Interface\ItemSocketingFrame\UI-ItemSockets]],
        get         = function(self) return self._File or (Scorpio.IsRetail and [[Interface\Artifacts\Artifacts]] or [[Interface\ItemSocketingFrame\UI-ItemSockets]]) end,
        set         = function(self, file)
            self._File = file
            for _, texture in ipairs(self.textures) do
                texture:SetTexture(file)
            end
        end
    }

    -- TexCoords of particle
    property "TexCoords"            {
        type        = RectType,
        default     = Scorpio.IsRetail and RectType(0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625) or RectType(0.3984375, 0.4453125, 0.40234375, 0.44921875),
        get         = function(self) return self._TexCoords or (Scorpio.IsRetail and RectType(0.8115234375, 0.9169921875, 0.8798828125, 0.9853515625) or RectType(0.3984375, 0.4453125, 0.40234375, 0.44921875)) end,
        set         = function(self, texCoords)
            self._TexCoords = texCoords
            for _, texture in ipairs(self.textures) do
                texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
            end
        end
    }

    -- BlendMode of particle
    property "AlphaMode"            {
        type        = AlphaMode,
        default     = Scorpio.IsRetail and "BLEND" or "ADD",
        get         = function(self) return self._AlphaMode or (Scorpio.IsRetail and "BLEND" or "ADD") end,
        set         = function(self, alphaMode)
            self._AlphaMode = alphaMode or "BLEND"
            for _, texture in ipairs(self.textures) do
                texture:SetBlendMode(alphaMode)
            end
        end
    }

    local function OnShow(self)
        UpdateFrameLevel(self)
        UpdatePoints(self)
        AddOrRemoveTextures(self)
        UpdateSizes(self)
    end

    local function OnHide(self)
        for _, texture in ipairs(self.textures) do
            self:ReleaseTexture(texture)
        end
        wipe(self.textures)
    end

    local function OnUpdate(self, elapsed)
        local width, height = self:GetSize()
        local groupNumber = self._GroupNumber or 4
        local period = self._Period or 8
        if width ~= self.info.width or height ~= self.info.height then
            self.info.width = width
            self.info.height = height
            self.info.perimeter = 2 * (width + height)
            self.info.bottomlim = height * 2 + width
            self.info.rightlim = height + width
            self.info.space = self.info.perimeter / groupNumber
        end

        local textureIndex = 0
        for k = 1, 4 do
            self.timer[k] = self.timer[k] + elapsed / (period * k)
            if self.timer[k] > 1 or self.timer[k] < -1 then
                self.timer[k] = self.timer[k] % 1
            end
            for i = 1, groupNumber do
                textureIndex = textureIndex + 1
                local texture = self.textures[textureIndex]
                if texture then
                    local position = (self.info.space * i + self.info.perimeter * self.timer[k]) % self.info.perimeter
                    if position > self.info.bottomlim then
                        texture:SetPoint("CENTER", self, "BOTTOMRIGHT", -position + self.info.bottomlim, 0)
                    elseif position > self.info.rightlim then
                        texture:SetPoint("CENTER", self, "TOPRIGHT", 0, -position + self.info.rightlim)
                    elseif position > self.info.height then
                        texture:SetPoint("CENTER", self, "TOPLEFT", position - self.info.height, 0)
                    else
                        texture:SetPoint("CENTER", self, "BOTTOMLEFT", 0, position)
                    end
                end
            end
        end
    end

    function __ctor(self)
        self.textures = {}
        self.timer = self.timer or { 0, 0, 0, 0 }
        self.info = self.info or {}
        self.OnShow = self.OnShow + OnShow
        self.OnHide = self.OnHide + OnHide
        self.OnUpdate = self.OnUpdate + OnUpdate
        self:Hide()
    end

end)


-------------------------------------------------
-- PixelGlow
-------------------------------------------------

__Sealed__()
__ChildProperty__(Frame, "PixelGlow")
__ChildProperty__(Frame, "PixelGlow1")
__ChildProperty__(Frame, "PixelGlow2")
__ChildProperty__(Frame, "PixelGlow3")
class "PixelGlow"(function(_ENV)
    inherit "Frame"
    extend "GlowAnimation"
    
    local function UpdateFrameLevel(self)
        local parent = self:GetParent()
        if parent then
            self:SetFrameLevel(parent:GetFrameLevel() + self.FrameLevel)
        end
    end

    local function UpdatePoints(self)
        local parent = self:GetParent()
        if parent then
            self:SetPoint("TOPLEFT", parent, "TOPLEFT", -self.PaddingHorizontal - 0.05, self.PaddingVertical + 0.05)
            self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", self.PaddingHorizontal + 0.05, -self.PaddingVertical - 0.05)
        end
    end

    local function UpdateMask1(self)
        local mask1 = self.masks[1]
        if not mask1 then
            mask1 = self:AcquireMaskTexture()
            mask1:SetTexture(PixelGlow.EmptyTexture, "CLAMPTOWHITE", "CLAMPTOWHITE")
            mask1:Show()
            self.masks[1] = mask1
        end
        local thickness = self.Thickness
        mask1:SetPoint("TOPLEFT", self, "TOPLEFT", thickness, -thickness)
        mask1:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -thickness, thickness)

        for _, texture in ipairs(self.textures) do
            if texture:GetNumMaskTextures() < 1 then
                texture:AddMaskTexture(self.masks[1])
            end
        end
    end

    local function UpdateBorder(self)
        if self.Border then
            local mask2 = self.masks[2]
            if not mask2 then
                mask2 = self:AcquireMaskTexture()
                mask2:SetTexture(PixelGlow.EmptyTexture,  "CLAMPTOWHITE", "CLAMPTOWHITE")
                self.masks[2] = mask2
            end
            local thickness = self.Thickness
            mask2:SetPoint("TOPLEFT", self, "TOPLEFT", thickness + 1, -thickness - 1)
            mask2:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -thickness-1, thickness + 1)

            if not self.bg then
                local bg = self:AcquireTexture()
                bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
                bg:SetParent(self)
                bg:SetAllPoints(self)
                bg:AddMaskTexture(mask2)
                self.bg = bg
            end
        else
            if self.bg then
                self:ReleaseTexture(self.bg)
                self.bg = nil
            end
            if self.masks[2] then
                self:ReleaseMaskTexture(self.masks[2])
                self.masks[2] = nil
            end
        end
    end

    local function AddOrRemoveTextures(self)
        local textureNumber = self.LineNumber
        for i = 1, textureNumber do
            local texture = self.textures[i]
            if not texture then
                texture = self:AcquireTexture()
                texture:SetParent(self)
                self.textures[i] = texture
            end
            texture:SetTexture(self.File)
            local texCoords = self.TexCoords
            texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
            texture:SetDesaturated(self.Desaturated)
            local color = self.Color
            texture:SetVertexColor(color.r, color.g, color.b, color.a)
            texture:SetBlendMode(self.AlphaMode)
            texture:Show()
        end

        while #self.textures > textureNumber do
            self:ReleaseTexture(self.textures[#self.textures])
            table.remove(self.textures)
        end
    end
    
    local function getAdjustLength(self, length)
        local width, height = self:GetSize()
        length = length or math.floor((width + height) * (2 / self.LineNumber - 0.1))
        return min(length, min(width, height))
    end

    __Static__()
    property "EmptyTexture" { set = false, default = [[Interface\AdventureMap\BrokenIsles\AM_29]] }

    -- Corresponding to the N param of the LibCustomGlow.PixelGlow_Start
    -- Number of lines
    property "LineNumber"           {
        type        = NaturalNumber,
        default     = 8,
        get         = function(self) return self._LineNumber or 8 end,
        set         = function(self, lineNumber)
            lineNumber = lineNumber > 0 and lineNumber or 8
            self._LineNumber = lineNumber
            self.step = 1/lineNumber
            AddOrRemoveTextures(self)
            UpdateMask1(self)
        end
    }

    -- Corresponding to the xoffset param of the LibCustomGlow.PixelGlow_Start
    -- Horizontal margin between glow and target frame
    property "PaddingHorizontal"    {
        type        = Number,
        default     = 0,
        get         = function(self) return self._PaddingHorizontal or 0 end,
        set         = function(self, paddingHorizontal)
            self._PaddingHorizontal = paddingHorizontal
            UpdatePoints(self)
        end
    }

    -- Corresponding to the yoffset param of the LibCustomGlow.PixelGlow_Start
    -- Vertical margin between glow and target frame    
    property "PaddingVertical"      {
        type        = Number,
        default     = 0,
        get         = function(self) return self._PaddingVertical or 0 end,
        set         = function(self, paddingVertical)
            self._PaddingVertical = paddingVertical
            UpdatePoints(self)
        end
    }

    -- Length of lines
    -- Default value depends on region size and number of lines
    property "Length"               {
        type        = Number,
        default     = nil,
        get         = function(self) if not self._Length then self._Length = getAdjustLength(self) end return self._Length end,
        set         = function(self, length)
            length = getAdjustLength(self, length)
            if length ~= self._Length then
                self.info.width = nil
                self._Length = length
            end
        end
    }

    -- Thickness of lines
    property "Thickness"            {
        type        = Number,
        default     = 1,
        get         = function(self) return self._Thickness or 1 end,
        set         = function(self, thickness)
            thickness = thickness > 0 and thickness or 1
            self._Thickness = thickness
            UpdateMask1(self)
            UpdateBorder(self)
        end
    }

    -- Corresponding to the frequency param of the LibCustomGlow.PixelGlow_Start
    -- Set to negative to inverse direction of rotation
    property "Period"               {
        type        = Number,
        default     = 4,
        get         = function(self) return self._Period or 4 end,
        set         = function(self, period)
            period = (period == 0) and 4 or period
            self._Period = period
        end
    }

    -- Whether glow texture is desaturated
    property "Desaturated"          {
        type        = Boolean,
        default     = true,
        get         = function(self) return self._Desaturated end,
        set         = function(self, desaturated)
            self._Desaturated = desaturated
            for _, texture in ipairs(self.textures) do
                texture:SetDesaturated(desaturated)
            end
        end
    }

    -- Glow color
    property "Color"                {
        type        = ColorType,
        default     = Color(0.95, 0.95, 0.32),
        get         = function(self) return self._Color or Color(0.95, 0.95, 0.32) end,
        set         = function(self, color)
            self._Color = color
            for _, texture in ipairs(self.textures) do
                texture:SetVertexColor(color.r, color.g, color.b, color.a)
            end
        end
    }

    -- FrameLevel of glow
    property "FrameLevel"           {
        type        = NaturalNumber,
        default     = 8,
        get         = function(self) return self._FrameLevel or 8 end,
        set         = function(self, frameLevel)
            self._FrameLevel = frameLevel
            UpdateFrameLevel(self)
        end
    }

    -- Texture file or fileID of line
    property "File"                 {
        type        = String + Number,
        default     = [[Interface\BUTTONS\WHITE8X8]],
        get         = function(self) return self._File or [[Interface\BUTTONS\WHITE8X8]] end,
        set         = function(self, file)
            self._File = file
            for _, texture in ipairs(self.textures) do
                texture:SetTexture(file)
            end
        end
    }

    -- TexCoords of line
    property "TexCoords"            {
        type        = RectType,
        default     = { 0, 1, 0, 1 },
        get         = function(self) return self._TexCoords or { 0, 1, 0, 1 } end,
        set         = function(self, texCoords)
            self._TexCoords = texCoords
            for _, texture in ipairs(self.textures) do
                texture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
            end
        end
    }

    -- BlendMode of line
    property "AlphaMode"            {
        type        = AlphaMode,
        default     = "BLEND",
        get         = function(self) return self._AlphaMode or "BLEND" end,
        set         = function(self, alphaMode)
            self._AlphaMode = alphaMode or "BLEND"
            for _, texture in ipairs(self.textures) do
                texture:SetBlendMode(alphaMode)
            end
        end
    }

    -- Whether show border
    property "Border"               {
        type        = Boolean,
        default     = false,
        get         = function(self) return self._Border end,
        set         = function(self, border)
            self._Border = border
            UpdateBorder(self)
        end
    }

    local function OnShow(self)
        UpdateFrameLevel(self)
        UpdatePoints(self)
        AddOrRemoveTextures(self)
        UpdateMask1(self)
        UpdateBorder(self)
    end

    local function OnHide(self)
        for _, texture in ipairs(self.textures) do
            self:ReleaseTexture(texture)
        end
        wipe(self.textures)

        if self.bg then
            self:ReleaseTexture(self.bg)
            self.bg = nil
        end

        for _, mask in pairs(self.masks) do
            self:ReleaseMaskTexture(mask)
        end
        wipe(self.masks)
    end

    -- update length
    local function OnSizeChanged(self)
        self.Length = self.Length
    end

    local pCalc1 = function(progress, s, th, p)
        local c
        if progress > p[3] or progress < p[0] then
            c = 0
        elseif progress > p[2] then
            c = s - th - (progress - p[2]) / (p[3] - p[2]) * (s - th)
        elseif progress > p[1] then
            c = s - th
        else
            c = (progress - p[0]) / (p[1] - p[0]) * (s - th)
        end
        return math.floor(c + 0.5)
    end
    
    local pCalc2 = function(progress, s, th, p)
        local c
        if progress > p[3] then
            c = s - th - (progress - p[3]) / (p[0] + 1 - p[3]) * (s - th)
        elseif progress > p[2] then
            c = s - th
        elseif progress > p[1] then
            c = (progress - p[1]) / (p[2] - p[1]) * (s - th)
        elseif progress > p[0] then
            c = 0
        else
            c = s - th - (progress + 1 - p[3]) / (p[0] + 1 - p[3]) * (s - th)
        end
        return math.floor(c + 0.5)
    end

    local function OnUpdate(self, elapsed)
        self.timer = self.timer + elapsed / (self._Period or 4)
        if self.timer > 1 or self.timer < -1 then
            self.timer = self.timer % 1
        end
        local progress = self.timer
        local width, height = self:GetSize()
        if width ~= self.info.width or height ~= self.info.height then
            local perimeter = 2 * ( width + height)
            if not (perimeter > 0) then
                return
            end
            local length = self.Length
            self.info.width = width
            self.info.height = height
            self.info.pTLx = {
                [0] = (height + length / 2) / perimeter,
                [1] = (height + width + length / 2) / perimeter,
                [2] = (2 * height + width - length / 2 ) / perimeter,
                [3] = 1- length / 2 / perimeter
            }
            self.info.pTLy ={
                [0] = (height-length / 2) / perimeter,
                [1] = (height + width + length / 2) / perimeter,
                [2] = (height * 2 + width + length / 2) / perimeter,
                [3] = 1- length / 2 / perimeter
            }
            self.info.pBRx ={
                [0] = length / 2 / perimeter,
                [1] = (height - length/ 2) / perimeter,
                [2] = (height + width - length / 2) / perimeter,
                [3] = (height * 2 + width + length / 2) / perimeter
            }
            self.info.pBRy ={
                [0] = length / 2 / perimeter,
                [1] = (height + length / 2) / perimeter,
                [2] = (height + width - length /2) / perimeter,
                [3] = (height * 2 + width - length /2) / perimeter
            }
        end
        local thickness = self._Thickness or 1
        self.step = self.step or 1/8
        if self:IsShown() then
            if not self.masks[1]:IsShown() then
                self.masks[1]:Show()
                self.masks[1]:SetPoint("TOPLEFT", self,"TOPLEFT", thickness, -thickness)
                self.masks[1]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -thickness, thickness)
            end
            if self.masks[2] and not self.masks[2]:IsShown() then
                self.masks[2]:Show()
                self.masks[2]:SetPoint("TOPLEFT", self, "TOPLEFT", thickness + 1, -thickness - 1)
                self.masks[2]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -thickness - 1,thickness + 1)
            end
            if self.bg and not self.bg:IsShown() then
                self.bg:Show()
            end
            for k, line in pairs(self.textures) do
                line:SetPoint("TOPLEFT", self, "TOPLEFT", pCalc1((progress + self.step *(k - 1)) % 1, width, thickness, self.info.pTLx), -pCalc2((progress + self.step * (k - 1)) % 1, height, thickness, self.info.pTLy))
                line:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", thickness + pCalc2((progress + self.step * (k - 1)) % 1, width, thickness, self.info.pBRx), -height + pCalc1((progress + self.step*(k - 1)) % 1, height, thickness, self.info.pBRy))
            end
        end
    end

    function __ctor(self)
        self.textures = {}
        self.masks = {}
        self.timer = self.timer or 0
        self.info = self.info or {}
        self.OnShow = self.OnShow + OnShow
        self.OnHide = self.OnHide + OnHide
        self.OnSizeChanged = self.OnSizeChanged + OnSizeChanged
        self.OnUpdate = self.OnUpdate + OnUpdate
        self:Hide()
    end

end)