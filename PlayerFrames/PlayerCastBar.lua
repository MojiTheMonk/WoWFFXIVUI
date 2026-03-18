local addonID, addonEnv = ...

local SCALE = 100
local function s(x) return x * SCALE / 100 end

local frame = CreateFrame("Frame", "PlayerCastBarFrame", UIParent)
frame:SetSize(s(232), s(230))
frame:SetPoint("CENTER", UIParent, "CENTER", s(0), s(0))
frame:SetFrameStrata("MEDIUM")
frame:Hide()

if PlayerCastingBarFrame then
    PlayerCastingBarFrame:UnregisterAllEvents()
    PlayerCastingBarFrame:Hide()
end

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Background")

local castBar = CreateFrame("StatusBar", nil, frame)
castBar:SetPoint("TOPLEFT", s(4), s(-4))
castBar:SetPoint("BOTTOMRIGHT", s(-4), s(4))
castBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\ClassResources\\Primary\\Mana")
castBar:SetMinMaxValues(0,1)
castBar:SetValue(0)
castBar:Hide()

local outlineFrame = CreateFrame("Frame", nil, frame)
outlineFrame:SetFrameStrata("MEDIUM")
outlineFrame:SetFrameLevel(frame:GetFrameLevel() + 5)
outlineFrame:SetSize(frame:GetWidth(), frame:GetHeight())
outlineFrame:SetPoint("CENTER", frame, "CENTER")
outlineFrame:EnableMouse(false)

local outline = outlineFrame:CreateTexture(nil, "OVERLAY")
outline:SetAllPoints()
outline:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\PlayerFrame\\Frame")
outline:SetDrawLayer("OVERLAY", 3)

local spellButton = CreateFrame("Button", nil, outlineFrame)
spellButton:SetSize(s(63), s(63))
spellButton:SetPoint("LEFT", outlineFrame, "LEFT", s(-65), s(-10))
spellButton:Hide()

spellButton.icon = spellButton:CreateTexture(nil, "ARTWORK")
spellButton.icon:SetAllPoints()
spellButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

spellButton.cooldown = CreateFrame("Cooldown", nil, spellButton, "CooldownFrameTemplate")
spellButton.cooldown:SetAllPoints()
spellButton.cooldown:SetDrawSwipe(true)

local Masque = LibStub and LibStub("Masque", true)
local MasqueGroup
if Masque then
    MasqueGroup = Masque:Group("FFXIV UI Player Cast Bar", "Player Cast Bar")
    MasqueGroup:AddButton(spellButton, { Icon = spellButton.icon, Cooldown = spellButton.cooldown })
end

local spellText = outlineFrame:CreateFontString(nil, "OVERLAY")
spellText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisRegular.ttf", s(18))
spellText:SetPoint("LEFT", outlineFrame, "LEFT", s(3), s(15))
spellText:SetJustifyH("RIGHT")
spellText:SetDrawLayer("OVERLAY", 7)
spellText:SetTextColor(252/255, 251/255, 250/255)
spellText:SetShadowColor(0.8196, 0.7804, 0.6980)
spellText:SetShadowOffset(0, -1)

local hpLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
hpLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MiedingerMedium.ttf", s(18))
hpLabel:SetPoint("BOTTOMLEFT", outlineFrame, "BOTTOMLEFT", s(2), s(75))
hpLabel:SetJustifyH("LEFT")
hpLabel:SetDrawLayer("OVERLAY", 7)
hpLabel:SetText("CASTING")
hpLabel:SetTextColor(252/255, 251/255, 250/255)
hpLabel:SetShadowColor(0.8196, 0.7804, 0.6980)
hpLabel:SetShadowOffset(0, -1)

local castTimeText = outlineFrame:CreateFontString(nil, "OVERLAY")
castTimeText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtended.ttf", s(32))
castTimeText:SetPoint("LEFT", hpLabel, "RIGHT", s(8), -3)
castTimeText:SetJustifyH("LEFT")
castTimeText:SetDrawLayer("OVERLAY", 7)
castTimeText:SetTextColor(252/255, 251/255, 250/255)
castTimeText:SetShadowColor(0.8196, 0.7804, 0.6980)
castTimeText:SetShadowOffset(0, -1)
castTimeText:SetText("00.00")

local interruptedFrame = CreateFrame("Frame", nil, frame)
interruptedFrame:SetFrameStrata("HIGH")
interruptedFrame:SetFrameLevel(frame:GetFrameLevel() + 50)
interruptedFrame:SetSize(frame:GetWidth(), frame:GetHeight())
interruptedFrame:SetPoint("CENTER", frame, "CENTER", -30, -10)

local interruptedText = interruptedFrame:CreateFontString(nil, "OVERLAY")
interruptedText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtendedBlack.ttf", 29)
interruptedText:SetTextColor(252/255, 251/255, 250/255)
interruptedText:SetShadowColor(0,0,0)
interruptedText:SetShadowOffset(1, -1)
interruptedText:SetText("INTERRUPTED")
interruptedText:SetDrawLayer("OVERLAY", 10)
interruptedText:SetJustifyH("CENTER")
interruptedText:Hide()

interruptedText.targetOffsetX = 0
interruptedText.startOffsetX = 50
interruptedText.currentOffsetX = interruptedText.startOffsetX
interruptedText.isAnimating = false
interruptedText:SetPoint("CENTER", interruptedFrame, "CENTER", interruptedText.currentOffsetX, 0)

local startTime, endTime = 0,0
local displayedProgress = 0
local hideTimer = 0
local frozenProgress = 0
local isChanneling = false

local function DarkenAll()
    bg:SetVertexColor(0.5,0.5,0.5)
    castBar:SetStatusBarColor(0.5,0.5,0.5)
    spellButton.icon:SetVertexColor(0.5,0.5,0.5)
    spellText:SetTextColor(252/255*0.5,251/255*0.5,250/255*0.5)
    spellText:SetShadowColor(0.8196*0.5,0.7804*0.5,0.6980*0.5)
    hpLabel:SetTextColor(252/255*0.5,251/255*0.5,250/255*0.5)
    hpLabel:SetShadowColor(0.8196*0.5,0.7804*0.5,0.6980*0.5)
    castTimeText:SetTextColor(252/255*0.5,251/255*0.5,250/255*0.5)
    castTimeText:SetShadowColor(0.8196*0.5,0.7804*0.5,0.6980*0.5)
end

local function RestoreAll()
    bg:SetVertexColor(1,1,1)
    castBar:SetStatusBarColor(1,1,1)
    spellButton.icon:SetVertexColor(1,1,1)
    spellText:SetTextColor(252/255,251/255,250/255)
    spellText:SetShadowColor(0.8196,0.7804,0.6980)
    hpLabel:SetTextColor(252/255,251/255,250/255)
    hpLabel:SetShadowColor(0.8196,0.7804,0.6980)
    castTimeText:SetTextColor(252/255,251/255,250/255)
    castTimeText:SetShadowColor(0.8196,0.7804,0.6980)
end

local fadeOutDuration = 0.25
local isFadingOut = false
local fadeElapsed = 0

local function CancelFadeOut()
    isFadingOut = false
    fadeElapsed = 0
    frame:SetAlpha(1)
    castBar:SetAlpha(1)
    spellButton:SetAlpha(1)
    spellButton.icon:SetAlpha(1)
    spellText:SetAlpha(1)
    hpLabel:SetAlpha(1)
    castTimeText:SetAlpha(1)
    interruptedText:SetAlpha(1)
    outlineFrame:SetAlpha(1)
end

castBar:SetScript("OnUpdate", function(self, elapsed)
    if hideTimer > 0 then
        hideTimer = hideTimer - elapsed
        castBar:SetValue(frozenProgress)
        local total = endTime - startTime
        if total == 0 then total = 1 end
        local remaining = total*(isChanneling and frozenProgress or 1 - frozenProgress)
        local sec = math.floor(remaining)
        local centi = math.floor((remaining-sec)*100)
        castTimeText:SetText(string.format("%02d.%02d", sec, centi))
        if hideTimer <= 0 then
            fadeElapsed = 0
            isFadingOut = true
            interruptedText.isFlashing = false
        end
        return
    end

    if isFadingOut then
        fadeElapsed = fadeElapsed + elapsed
        local alpha = math.max(0, 1 - fadeElapsed / fadeOutDuration)
        frame:SetAlpha(alpha)
        castBar:SetAlpha(alpha)
        spellButton:SetAlpha(alpha)
        spellButton.icon:SetAlpha(alpha)
        spellText:SetAlpha(alpha)
        hpLabel:SetAlpha(alpha)
        castTimeText:SetAlpha(alpha)
        interruptedText:SetAlpha(alpha)
        outlineFrame:SetAlpha(alpha)
        if alpha <= 0 then
            if startTime ~= 0 then
                isFadingOut = false
                return
            end
            isFadingOut = false
            frame:Hide()
            castBar:Hide()
            spellButton:Hide()
            spellText:SetText("")
            castTimeText:SetText("00.00")
            interruptedText:Hide()
            frame:SetAlpha(1)
            castBar:SetAlpha(1)
            spellButton:SetAlpha(1)
            spellButton.icon:SetAlpha(1)
            spellText:SetAlpha(1)
            hpLabel:SetAlpha(1)
            castTimeText:SetAlpha(1)
            interruptedText:SetAlpha(1)
            outlineFrame:SetAlpha(1)
            displayedProgress = 0
            frozenProgress = 0
            startTime, endTime = 0, 0
            isChanneling = false
            RestoreAll()
        end
    end

    if not self:IsShown() or startTime == 0 or endTime == 0 then
        castTimeText:SetText("00.00")
        return
    end

    local now = GetTime()
    local total = endTime - startTime
    local progress
    if isChanneling then
        progress = 1 - (now - startTime) / total
    else
        progress = (now - startTime) / total
    end
    progress = math.max(0, math.min(1, progress))

    local smoothSpeed = 10
    displayedProgress = displayedProgress + (progress - displayedProgress) * math.min(elapsed * smoothSpeed, 1)
    castBar:SetValue(displayedProgress)

    local remaining = math.max(0, isChanneling and total * displayedProgress or total * (1 - displayedProgress))
    local sec = math.floor(remaining)
    local centi = math.floor((remaining - sec) * 100)
    castTimeText:SetText(string.format("%02d.%02d", sec, centi))

    if (not isChanneling and progress >= 1) or (isChanneling and progress <= 0) then
        castBar:Hide()
        frame:Hide()
        spellText:SetText("")
        spellButton:Hide()
        castTimeText:SetText("00.00")
        startTime, endTime = 0, 0
        displayedProgress = 0
        isChanneling = false
    end
end)

interruptedFrame:SetScript("OnUpdate", function(self, elapsed)
    if interruptedText.isAnimating then
        local speed = 300
        local direction = -1
        interruptedText.currentOffsetX = interruptedText.currentOffsetX + direction * speed * elapsed
        if interruptedText.currentOffsetX <= interruptedText.targetOffsetX then
            interruptedText.currentOffsetX = interruptedText.targetOffsetX
            interruptedText.isAnimating = false
            interruptedText.flashCount = 0
            interruptedText.flashTimer = 0.25
            interruptedText.isFlashing = true
        end
        interruptedText:SetPoint("CENTER", interruptedFrame, "CENTER", interruptedText.currentOffsetX, 0)
    end

    if interruptedText.isFlashing then
        interruptedText.flashTimer = interruptedText.flashTimer - elapsed
        if interruptedText.flashTimer <= 0 then
            if interruptedText:IsShown() then
                interruptedText:Hide()
            else
                interruptedText:Show()
            end
            interruptedText.flashCount = interruptedText.flashCount + 0.5
            if interruptedText.flashCount >= 4 then
                interruptedText.isFlashing = false
                interruptedText:Hide()
            else
                interruptedText.flashTimer = 0.25
            end
        end
    end
end)

frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
frame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")

frame:SetScript("OnEvent", function(self, event, unit)
    if unit ~= "player" then return end

    local function ResetCastBar()
        frame:Hide()
        castBar:Hide()
        spellButton:Hide()
        spellText:SetText("")
        castTimeText:SetText("00.00")
        interruptedText:Hide()
        interruptedText.isAnimating = false
        interruptedText.isFlashing = false
        interruptedText.flashCount = 0
        interruptedText.flashTimer = 0
        interruptedText.currentOffsetX = interruptedText.startOffsetX
        interruptedText:SetPoint("CENTER", interruptedFrame, "CENTER", interruptedText.currentOffsetX, 0)
        displayedProgress = 0
        frozenProgress = 0
        startTime, endTime = 0, 0
        isChanneling = false
        RestoreAll()
    end

    if event == "UNIT_SPELLCAST_EMPOWER_START" then
        ResetCastBar()
        return
    end

    if event == "UNIT_SPELLCAST_START" then
        local spellName, _, spellIconPath, startMS, endMS = UnitCastingInfo("player")
        if not spellName then return end

        CancelFadeOut()

        interruptedText:Hide()
        interruptedText.isAnimating = false
        interruptedText.isFlashing = false

        startTime = startMS / 1000
        endTime = endMS / 1000
        displayedProgress = 0
        frozenProgress = 0
        hideTimer = 0
        isChanneling = false
        castBar:SetValue(0)
        frame:Show()
        castBar:Show()
        spellText:SetText(spellName)
        RestoreAll()

        if spellIconPath then
            spellButton.icon:SetTexture(spellIconPath)
            spellButton:Show()
            if MasqueGroup then MasqueGroup:ReSkin(spellButton) end
        end

    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local spellName, _, spellIconPath, startMS, endMS = UnitChannelInfo("player")
        if not spellName then return end

        CancelFadeOut()

        interruptedText:Hide()
        interruptedText.isAnimating = false
        interruptedText.isFlashing = false

        startTime = GetTime()
        endTime = startTime + (endMS - startMS) / 1000
        displayedProgress = 1
        frozenProgress = 1
        hideTimer = 0
        isChanneling = true
        castBar:SetValue(displayedProgress)
        frame:Show()
        castBar:Show()
        spellText:SetText(spellName)
        RestoreAll()

        if spellIconPath then
            spellButton.icon:SetTexture(spellIconPath)
            spellButton:Show()
            if MasqueGroup then MasqueGroup:ReSkin(spellButton) end
        end

    else
        if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            if isChanneling then
                if not UnitChannelInfo("player") then
                    ResetCastBar()
                    return
                end
                hideTimer = 2.2
                frozenProgress = displayedProgress
                startTime = 0
                endTime = 0
                DarkenAll()
                if not interruptedText:IsShown() then
                    interruptedText.currentOffsetX = interruptedText.startOffsetX
                    interruptedText.isAnimating = true
                    interruptedText:SetPoint("CENTER", interruptedFrame, "CENTER", interruptedText.currentOffsetX, 0)
                    interruptedText:Show()
                end
                return
            end
        end

        if event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
            local stillCasting = UnitCastingInfo("player")
            local stillChanneling = UnitChannelInfo("player")
            if stillCasting or stillChanneling then return end

            hideTimer = 2.2
            frozenProgress = displayedProgress
            startTime = 0
            endTime = 0
            DarkenAll()

            if not interruptedText:IsShown() then
                interruptedText.currentOffsetX = interruptedText.startOffsetX
                interruptedText.isAnimating = true
                interruptedText:SetPoint("CENTER", interruptedFrame, "CENTER", interruptedText.currentOffsetX, 0)
                interruptedText:Show()
            end
        end
    end
end)

local anchor = FFXIV_UI_Anchors.PlayerCast
frame:SetParent(anchor)
frame:ClearAllPoints()
frame:SetPoint("CENTER", anchor, "CENTER", 0, 0)