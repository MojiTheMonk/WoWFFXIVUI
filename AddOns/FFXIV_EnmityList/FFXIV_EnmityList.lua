-- Create the main frame to hold the list of enemies
local frame = CreateFrame("Frame", "FFXIVEnmityListFrame", UIParent)
frame:SetSize(230, 50)  -- Initial size of the box (width x height)
frame:SetPoint("LEFT", UIParent, "LEFT", 10, 0)  -- Position the frame to the left side of the screen

-- Enable mouse interaction for the frame
frame:SetMovable(true)  -- Make the frame movable
frame:EnableMouse(true)  -- Enable mouse interaction
frame:SetClampedToScreen(true)  -- Keep the frame within the screen bounds

-- Allow the frame to be dragged
frame:RegisterForDrag("LeftButton")  -- Register for left button dragging
frame:SetScript("OnDragStart", function(self)
    self:StartMoving()  -- Start moving when the user clicks and drags
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()  -- Stop moving when the drag ends
    -- Optionally, you can save the position of the frame here
end)

-- Create a background for the frame (optional)
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityBarBGMiddle.tga")
frame.bg:SetAllPoints(frame)  -- Make the background fill the entire frame

-- Create a custom top border using FFEnmityBarBGTop.tga
frame.topBorder = frame:CreateTexture(nil, "ARTWORK")
frame.topBorder:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityBarBGTop.tga")
frame.topBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 150)
frame.topBorder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 150)
frame.topBorder:SetHeight(150)  -- Set height of the top border

-- Create a custom bottom border using FFEnmityBarBGBottom.tga
frame.bottomBorder = frame:CreateTexture(nil, "ARTWORK")
frame.bottomBorder:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityBarBGBottom.tga")
frame.bottomBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, -150)
frame.bottomBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -150)
frame.bottomBorder:SetHeight(150)  -- Set height of the bottom border

-- Create a child frame for the list content (enemies)
local contentFrame = CreateFrame("Frame", nil, frame)
contentFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)  -- Position it inside the border
contentFrame:SetSize(220, 200)  -- Set the size of the content area

-- Table to keep track of the enemies the player is in combat with
local aggroList = {}

-- Function to update the enmity list
local function UpdateEnmityList()
    -- Clear previous health bars, health bar backgrounds, and text
    if contentFrame.healthBars then
        for _, bar in pairs(contentFrame.healthBars) do
            bar:Hide()
            bar:ClearAllPoints()
        end
    end
    if contentFrame.healthBarBGs then
        for _, bg in pairs(contentFrame.healthBarBGs) do
            bg:Hide()
            bg:ClearAllPoints()
        end
    end
    if contentFrame.names then
        for _, name in pairs(contentFrame.names) do
            name:Hide()
            name:ClearAllPoints()
        end
    end
    if contentFrame.targetIcons then
        for _, icon in pairs(contentFrame.targetIcons) do
            icon:Hide()
            icon:ClearAllPoints()
        end
    end
    if contentFrame.threatIcons then
        for _, icon in pairs(contentFrame.threatIcons) do
            icon:Hide()
            icon:ClearAllPoints()
        end
    end
    contentFrame.healthBars = {}
    contentFrame.healthBarBGs = {}
    contentFrame.names = {}
    contentFrame.targetIcons = {}
    contentFrame.threatIcons = {}

    -- Get the threat list for the player, considering all enemies in combat
    if UnitAffectingCombat("player") then
        for i = 1, 40 do  -- Checking up to 40 mobs in range
            local unitID = "nameplate"..i  -- Loop through possible nameplates
            local threatStatus = UnitThreatSituation("player", unitID)

            -- Only add enemies that the player is in combat with and have threat
            if threatStatus and threatStatus > 0 and UnitAffectingCombat(unitID) then
                local name = UnitName(unitID)
                if name and UnitIsEnemy("player", unitID) then  -- Ensure this unit is an enemy
                    aggroList[unitID] = true  -- Add to the aggro list
                end
            end
        end
    end

    -- Check if player is targeting an enemy or if the enemy targets the player or a party member
    if UnitAffectingCombat("player") then
        for i = 1, 40 do  -- Checking up to 40 nameplates
            local unitID = "nameplate"..i  -- Loop through possible nameplates
            local name = UnitName(unitID)

            if name and not aggroList[unitID] and UnitIsEnemy("player", unitID) then  -- Only add enemies, not friendly units
                -- Check if the enemy has targeted the player or a party member
                if UnitIsUnit("target", unitID) or 
                   UnitIsUnit("player", unitID) or
                   UnitIsUnit("party1", unitID) or 
                   UnitIsUnit("party2", unitID) or 
                   UnitIsUnit("party3", unitID) or 
                   UnitIsUnit("party4", unitID) then
                    if UnitAffectingCombat(unitID) then
                        aggroList[unitID] = true  -- Add to the aggro list if targeted and in combat
                    end
                end
            end
        end
    end

    -- Remove units without threatStatus or that are no longer in combat
    for unitID, _ in pairs(aggroList) do
        local threatStatus = UnitThreatSituation("player", unitID)
        if not threatStatus or not UnitAffectingCombat(unitID) then
            aggroList[unitID] = nil  -- Remove from the aggro list
        end
    end

    -- Create enemies in the list with dynamic size adjustments
    local yOffset = 0  -- Vertical offset for each enemy
    local xOffset = -25  -- Horizontal offset for positioning the enemy name
    local baseHeight = 35  -- Base height of each enemy's row (including name and health bar)

    for unitID, _ in pairs(aggroList) do
        local name = UnitName(unitID)
        local health = UnitHealth(unitID)
        local healthMax = UnitHealthMax(unitID)
        local threatStatus = UnitThreatSituation("player", unitID)

        -- Check if the enemy is dead (health is 0)
        if health == 0 then
            -- Remove this unit from the aggro list if it is dead
            aggroList[unitID] = nil
        else
            -- Check if the player is targeting this enemy
            local isTargeting = UnitIsUnit("target", unitID)

            -- Create a text label for the enemy's name
            local nameText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", xOffset + 35, -(yOffset-5))  -- Offset for the image
            nameText:SetText(name)
            nameText:SetTextColor(0.984, 0.922, 0.780)  -- Default color (fffdf2)
            nameText:SetFont("Interface\\AddOns\\SharedMedia_MyMedia\\font\\AxisMedium.ttf", 14)
            nameText:Show()

            -- Store the name label for cleanup later
            table.insert(contentFrame.names, nameText)

            -- Create the health bar background
            local healthBarBG = CreateFrame("StatusBar", nil, contentFrame)
            healthBarBG:SetSize(67, 67)  -- Set the background size
            healthBarBG:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, 25)
            healthBarBG:SetStatusBarTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityBarBG.tga")
            healthBarBG:SetFrameLevel(3)
            healthBarBG:SetAlpha(1)
            healthBarBG:Show()

            -- Store the health bar background for cleanup later
            table.insert(contentFrame.healthBarBGs, healthBarBG)

            -- Create the health bar
            local healthBar = CreateFrame("StatusBar", nil, contentFrame)
            healthBar:SetSize(59, 43)
            healthBar:SetPoint("TOPLEFT", healthBarBG, "TOPLEFT", 4, -12)
            healthBar:SetMinMaxValues(0, healthMax)
            healthBar:SetValue(health)
            healthBar:SetStatusBarTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityBar.tga")
            healthBar:SetFrameLevel(4)
            healthBar:Show()

            -- Store the health bar for cleanup later
            table.insert(contentFrame.healthBars, healthBar)

            -- Determine the threat image to show
            if threatStatus then
                -- Create a frame to contain the threat icon and set its frame level
                local threatFrame = CreateFrame("Frame", nil, contentFrame)
                threatFrame:SetFrameLevel(4)  -- Set frame level here, not on the texture
                threatFrame:SetSize(20, 20)  -- Set the size of the frame that holds the threat icon
                threatFrame:SetPoint("CENTER", healthBar, "CENTER", -44, 15)  -- Anchor it directly to the health bar's center

                -- Create the threat icon as a texture inside the threatFrame
                local threatIcon = threatFrame:CreateTexture(nil, "OVERLAY")

                -- Set the appropriate texture based on threatStatus
                if threatStatus == 3 then
                    threatIcon:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityRed.tga")  -- Red when targeted
                elseif threatStatus == 2 then
                    threatIcon:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityOrange.tga")  -- Orange with high threat
                elseif threatStatus == 1 then
                    threatIcon:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityYellow.tga")  -- Yellow with some threat
                else
                    threatIcon:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityGreen.tga")  -- Green with no threat
                end

                -- Make the icon fill the entire threat frame
                threatIcon:SetAllPoints(threatFrame)
                threatIcon:Show()

                -- Store the threat frame (not just the icon) for cleanup later
                table.insert(contentFrame.threatIcons, threatFrame)
            end

            -- Create the target icon next to the health bar if the player is targeting the enemy
            if isTargeting then
                -- Create a frame to contain the target icon and set its frame level
                local targetFrame = CreateFrame("Frame", nil, contentFrame)
                targetFrame:SetFrameLevel(2)  -- Set frame level here, not on the texture
                targetFrame:SetSize(190, 160)  -- Set the size of the frame that holds the target icon
                targetFrame:SetPoint("LEFT", healthBar, "LEFT", -31, 8)  -- Position the frame next to the health bar

                -- Create the target icon as a texture inside the targetFrame
                local targetIcon = targetFrame:CreateTexture(nil, "OVERLAY")
                targetIcon:SetTexture("Interface\\AddOns\\FFXIV_EnmityList\\FFEnmityTarget.tga")
                targetIcon:SetAllPoints(targetFrame)  -- Make the icon fill the entire frame
                targetIcon:Show()

                -- Store the target frame in the list for cleanup later
                table.insert(contentFrame.targetIcons, targetFrame)
            end

            -- Increase the yOffset for the next enemy's name and health bar
            yOffset = yOffset + baseHeight
        end
    end

    -- Adjust the size of the content frame to fit all enemies
    contentFrame:SetSize(220, yOffset + 10)  -- Add some padding for spacing

    -- Adjust the height of the main frame based on the content
    frame:SetSize(230, yOffset - 5)  -- Keep the border and padding

    -- Adjust the alpha of the background and borders based on whether the aggro list is empty
    if next(aggroList) == nil then  -- Check if the aggro list is empty
        frame.bg:SetAlpha(0)
        frame.topBorder:SetAlpha(0)
        frame.bottomBorder:SetAlpha(0)
    else
        frame.bg:SetAlpha(1)
        frame.topBorder:SetAlpha(1)
        frame.bottomBorder:SetAlpha(1)
    end
end

-- Event handler for updating the aggro list when the player changes targets or the game updates
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Detect when the player exits combat
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Detect when the player enters combat
frame:RegisterEvent("UNIT_HEALTH")  -- Detect when a unit's health changes
frame:RegisterEvent("UNIT_DAMAGE")  -- Detect when a unit takes damage

-- Hide the frame initially
frame:Hide()  -- Ensure the frame is hidden when the game starts

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "PLAYER_REGEN_ENABLED" then
        -- Player has left combat, hide the frame and borders
        frame:Hide()  -- Hide the main frame
        frame.topBorder:Hide()  -- Hide the top border
        frame.bottomBorder:Hide()  -- Hide the bottom border

        -- Clear the aggro list and reset UI elements
        aggroList = {}
        UpdateEnmityList()  -- Optionally call to clean up UI elements when leaving combat
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Player has entered combat, show the frame and borders
        frame:Show()  -- Show the main frame
        frame.topBorder:Show()  -- Show the top border
        frame.bottomBorder:Show()  -- Show the bottom border

        UpdateEnmityList()  -- Update the UI when entering combat
    elseif event == "UNIT_DAMAGE" then
        -- If the player damages a unit, add it to the aggro list (even if no threat)
        if arg1 == "player" then
            -- Check all possible nameplates (i.e., all enemies in combat)
            for i = 1, 40 do
                local unitID = "nameplate"..i
                local name = UnitName(unitID)
                
                -- Add the enemy to the list if it's not already there and is an enemy
                if name and not aggroList[unitID] and UnitIsEnemy("player", unitID) then
                    aggroList[unitID] = true
                    UpdateEnmityList()  -- Update the UI immediately
                end
            end
        end
    else
        -- Update the enmity list when other events occur
        UpdateEnmityList()
    end
end)
