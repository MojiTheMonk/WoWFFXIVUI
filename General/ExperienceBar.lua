--print("FFXIV UI Player XP Frame loaded")

local SCALE = 100
local function s(x) return x * SCALE / 100 end

FFPlayerXPFrame = CreateFrame("Frame", "PlayerXPFrame", UIParent)
local f = FFPlayerXPFrame
f:SetSize(s(750), s(750))
f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, s(-330))
f:SetFrameStrata("MEDIUM")

local anchor = FFXIV_UI_Anchors.ExpBar
f:SetParent(anchor)
f:ClearAllPoints()
f:SetPoint("CENTER", anchor, "CENTER", 0, 0)

local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\ExperienceBar\\XPBG")

local restedBar = CreateFrame("StatusBar", nil, f)
restedBar:SetAllPoints()
restedBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\ExperienceBar\\XPRested")
restedBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -1)
restedBar:SetMinMaxValues(0, 1)
restedBar:SetValue(0)
restedBar:Hide()

local xpBar = CreateFrame("StatusBar", nil, f)
xpBar:SetAllPoints()
xpBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\ExperienceBar\\XPBar")
xpBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", 0)

local outlineFrame = CreateFrame("Frame", nil, f)
outlineFrame:SetFrameLevel(f:GetFrameLevel() + 5)
outlineFrame:SetAllPoints()
outlineFrame:EnableMouse(false)

local classLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
classLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MavenPro-Bold.ttf", s(18))
classLabel:SetPoint("LEFT", outlineFrame, "LEFT", s(-5), s(-15))
classLabel:SetShadowOffset(1, -1)
classLabel:SetShadowColor(0.8196, 0.7804, 0.6980)  

local LLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
LLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MavenPro-Bold.ttf", s(18))
LLabel:SetPoint("LEFT", classLabel, "RIGHT", s(4), 0)
LLabel:SetText("L")
LLabel:SetShadowOffset(1, -1)
LLabel:SetShadowColor(0.8196, 0.7804, 0.6980)  

local vLabel = outlineFrame:CreateFontString(nil, "OVERLAY")
vLabel:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\MavenPro-Bold.ttf", s(18))
vLabel:SetPoint("LEFT", LLabel, "LEFT", s(8), 0)
vLabel:SetText("v")
vLabel:SetShadowOffset(1, -1)
vLabel:SetShadowColor(0.8196, 0.7804, 0.6980)  

local levelText = outlineFrame:CreateFontString(nil, "OVERLAY")
levelText:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\EurostileExtendedBlack.ttf", s(18))
levelText:SetPoint("LEFT", vLabel, "RIGHT", 0, -1)
levelText:SetShadowOffset(1, -1)
levelText:SetShadowColor(0.8196, 0.7804, 0.6980)  

local xpNumbers = outlineFrame:CreateFontString(nil, "OVERLAY")
xpNumbers:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", s(16))
xpNumbers:SetPoint("LEFT", levelText, "RIGHT", s(50), 1)
xpNumbers:SetShadowOffset(0, -1)
xpNumbers:SetShadowColor(0.8196, 0.7804, 0.6980)  

local xpPercent = outlineFrame:CreateFontString(nil, "OVERLAY")
xpPercent:SetFont("Interface\\AddOns\\FFXIV_UI\\Media\\Fonts\\AxisMedium.ttf", s(16))
xpPercent:SetPoint("LEFT", xpNumbers, "RIGHT", s(5), 0)
xpPercent:SetShadowOffset(0, -1)
xpPercent:SetShadowColor(0.8196, 0.7804, 0.6980)  
 

local restedIndicator = f:CreateTexture(nil, "OVERLAY")
restedIndicator:SetTexture("Interface\\AddOns\\FFXIV_UI\\Media\\Textures\\ExperienceBar\\FFRested")
restedIndicator:SetSize(s(180), s(180))
restedIndicator:SetPoint("LEFT", f, "RIGHT", s(-75), -11)
restedIndicator:Hide()

local CLASS_ABBR = {
    WARRIOR     = "WAR",
    PALADIN     = "PLD",
    HUNTER      = "HUN",
    ROGUE       = "ROG",
    PRIEST      = "PRI",
    DEATHKNIGHT = "DKN",
    SHAMAN      = "SHM",
    MAGE        = "MAG",
    WARLOCK     = "WLK",
    MONK        = "MNK",
    DRUID       = "DRU",
    DEMONHUNTER = "DHM",
    EVOKER      = "EV0",
}

local function HideDefaultXPBar()
    if MainMenuExpBar then
        MainMenuExpBar:UnregisterAllEvents()
        MainMenuExpBar:Hide()
    end
    if StatusTrackingBarManager then
        StatusTrackingBarManager:UnregisterAllEvents()
        StatusTrackingBarManager:Hide()
    end
end

HideDefaultXPBar()

local function UpdateXP()
    local currXP  = UnitXP("player")
    local maxXP   = UnitXPMax("player")
    local rested  = GetXPExhaustion() or 0
    local percent = maxXP > 0 and (currXP / maxXP) * 100 or 0

    levelText:SetText(UnitLevel("player"))
    classLabel:SetText(CLASS_ABBR[select(2, UnitClass("player"))] or "")

    xpBar:SetMinMaxValues(0, maxXP)
    xpBar:SetValue(currXP)

    if rested > 0 then
        restedBar:SetMinMaxValues(0, maxXP)
        restedBar:SetValue(math.min(currXP + rested, maxXP))
        restedBar:Show()
    else
        restedBar:Hide()
    end

    restedIndicator:SetShown(IsResting())

    xpNumbers:SetText(string.format("EXP %d/%d", currXP, maxXP))
    xpPercent:SetText(string.format("(%.0f%%)", percent))
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_UPDATE_RESTING")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")

f:SetScript("OnEvent", UpdateXP)
UpdateXP()
 