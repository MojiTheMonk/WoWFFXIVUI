-- Create a frame to listen to nameplate events
local ffxivNameplatesFrame = CreateFrame("Frame", "FFXIV_NameplatesFrame", UIParent)

-- Disable Blizzard's default nameplates
SetCVar("nameplateShowAll", 0)  -- Disable all default nameplates
SetCVar("nameplateShowSelf", 0) -- Disable your own nameplate
SetCVar("nameplateShowFriendly", 0) -- Disable friendly nameplates
SetCVar("nameplateShowEnemies", 1) -- Show enemy nameplates
SetCVar("nameplateMaxDistance", 50)  -- Optional: Set max distance for nameplates

-- Function to get color based on unit reaction
local function GetReactionColor(unit)
    if not unit then
        print("Error: Unit is nil.")
        return 0, 0, 0  -- Return black or any fallback color
    end

    -- Ensure unit string is valid for UnitReaction
    if type(unit) ~= "string" or unit == "" then
        --print("Error: Invalid unit string:", unit)
        return 248/255, 154/255, 161/255
    end

    -- Try getting the reaction and handle if it's nil
    local reaction = UnitReaction(unit, "player")

   if reaction == nil then
        --print("Error: Reaction is nil for unit:", unit)
        return 248/255, 154/255, 161/255
    end

    -- Handle valid reaction values
    if reaction == 1 or reaction == 2 or reaction == 3 then
        return 248/255, 154/255, 161/255  -- Hostile 
    elseif reaction == 4 then
        return 255/255, 224/255, 200/255  -- Neutral 
    else
        return 0, 1, 0  -- Default to friendly 
    end
end





-- Function to update nameplate color and health bar texture based on combat state
local function UpdateNameplateColorAndTexture(unit, nameplate)
    local reaction = UnitReaction(unit, "player")
    local r, g, b = GetReactionColor(reaction)

    -- Initialize texture variables
    local healthBarTexture, healthBarBackdrop

    -- Check if the unit is neutral
    if reaction == 4 then
        -- If the unit is neutral and the player is in combat with it, apply hostile appearance
        if UnitAffectingCombat(unit) then
            -- Apply hostile appearance for neutral units in combat
            healthBarTexture = "Interface\\FFXIVUI\\HostileHPBar.tga"
            healthBarBackdrop = "Interface\\FFXIVUI\\HostileHPBackdrop.tga"
            r, g, b = 248/255, 154/255, 161/255  -- Hostile color 
        else
            -- Neutral units not in combat
            healthBarTexture = "Interface\\FFXIVUI\\NeutralHPBar.tga"
            healthBarBackdrop = "Interface\\FFXIVUI\\NeutralHPBackdrop.tga"
            r, g, b = 250/255, 243/255, 172/255  -- Neutral color 
        end
    elseif reaction == 1 or reaction == 2 or reaction == 3 then
        -- Hostile enemies use Hostile textures
        healthBarTexture = "Interface\\FFXIVUI\\HostileHPBar.tga"
        healthBarBackdrop = "Interface\\FFXIVUI\\HostileHPBackdrop.tga"
    elseif reaction >= 5 then
        -- Friendly NPCs or players
        if UnitIsPlayer(unit) then
            -- Friendly players use FriendlyPlayer textures
            healthBarTexture = "Interface\\FFXIVUI\\FriendlyPlayerHPBar.tga"
            healthBarBackdrop = "Interface\\FFXIVUI\\FriendlyPlayerHPBackdrop.tga"
            -- Set the name color for friendly players to (light cyan)
            r, g, b = 232/255, 255/255, 254/255  -- (light cyan)
        else
            -- Friendly NPCs use FriendlyNPC textures
            healthBarTexture = "Interface\\FFXIVUI\\FriendlyNPCHPBar.tga"
            healthBarBackdrop = "Interface\\FFXIVUI\\FriendlyNPCHPBackdrop.tga"
            -- Set the name color for friendly NPCs to (light green)
            r, g, b = 209/255, 244/255, 186/255  
        end
    end

    -- Ensure healthBarTexture and healthBarBackdrop are valid before applying
    if healthBarTexture and healthBarBackdrop then
        -- Set health bar texture and backdrop
        if nameplate.HealthBar then
            nameplate.HealthBar:SetStatusBarTexture(healthBarTexture)
        end
        if nameplate.HealthBarBackground then
            -- Keep the backdrop static, without updating it every time
            nameplate.HealthBarBackground:SetBackdrop({
                bgFile = healthBarBackdrop,  -- Set appropriate backdrop texture
                insets = {left = 2, right = 2, top = 2, bottom = 2}  -- Insets for inner spacing
            })
        end
    end

    -- Set the text color for the nameplate
    nameplate.LvText:SetTextColor(r, g, b)
    nameplate.LevelText:SetTextColor(r, g, b)
    nameplate.NameText:SetTextColor(r, g, b)
    
    -- Set the guild text color to match the player's name color
    if nameplate.GuildText then
        nameplate.GuildText:SetTextColor(r, g, b)
    end

    -- Apply drop shadow for friendly player and NPC names
    if UnitIsPlayer(unit) then
        -- For friendly players, apply a drop shadow with color #172d43 (dark blue)
        local shadowColor = {23/255, 45/255, 67/255}  -- #172d43 color (dark blue)
        nameplate.NameText:SetShadowColor(unpack(shadowColor))  -- Apply to NameText
        if nameplate.GuildText then
            nameplate.GuildText:SetShadowColor(unpack(shadowColor))  -- Apply to GuildText
        end
    elseif not UnitIsPlayer(unit) and UnitReaction(unit, "player") == 4 then
        -- For neutral NPCs, apply a drop shadow with color #716737 (olive brown)
        local shadowColor = {113/255, 103/255, 55/255}  -- #716737 color (olive brown)
        
        -- Apply the olive brown shadow color to NameText, LvText, and LevelText
        nameplate.NameText:SetShadowColor(unpack(shadowColor))
        if nameplate.GuildText then
            nameplate.GuildText:SetShadowColor(unpack(shadowColor))  -- Apply to GuildText
        end
        nameplate.LvText:SetShadowColor(unpack(shadowColor))
        nameplate.LevelText:SetShadowColor(unpack(shadowColor))
    elseif not UnitIsPlayer(unit) and UnitReaction(unit, "player") <= 3 then
        -- For Hostile NPCs, apply a red drop shadow  
        local shadowColor = {188/255, 33/255, 41/255}   
        
        -- Apply the olive brown shadow color to NameText, LvText, and LevelText
        nameplate.NameText:SetShadowColor(unpack(shadowColor))
        if nameplate.GuildText then
            nameplate.GuildText:SetShadowColor(unpack(shadowColor))  -- Apply to GuildText
        end
        nameplate.LvText:SetShadowColor(unpack(shadowColor))
        nameplate.LevelText:SetShadowColor(unpack(shadowColor))
    elseif not UnitIsPlayer(unit) and UnitReaction(unit, "player") >= 5 then
        -- For friendly NPCs, apply a green drop shadow  
        local shadowColor = {75/255, 118/255, 43/255}   
        
        -- Apply the olive brown shadow color to NameText, LvText, and LevelText
        nameplate.NameText:SetShadowColor(unpack(shadowColor))
        if nameplate.GuildText then
            nameplate.GuildText:SetShadowColor(unpack(shadowColor))  -- Apply to GuildText
        end
        nameplate.LvText:SetShadowColor(unpack(shadowColor))
        nameplate.LevelText:SetShadowColor(unpack(shadowColor))
    else
        -- For other NPCs, apply the default shadow or none
        nameplate.NameText:SetShadowColor(0, 0, 0)  -- Default shadow color (black)
        if nameplate.GuildText then
            nameplate.GuildText:SetShadowColor(0, 0, 0)  -- Default shadow color (black)
        end
        nameplate.LvText:SetShadowColor(0, 0, 0)  -- Default shadow color (black)
        nameplate.LevelText:SetShadowColor(0, 0, 0)  -- Default shadow color (black)
    end

    -- Set the shadow offset for NameText, LvText, LevelText, and GuildText
    nameplate.NameText:SetShadowOffset(1, -1)
    if nameplate.GuildText then
        nameplate.GuildText:SetShadowOffset(1, -1)  -- Set shadow offset for GuildText
    end
    nameplate.LvText:SetShadowOffset(1, -1)
    nameplate.LevelText:SetShadowOffset(1, -1)
    
    -- Only show Lv and LevelText if the unit is attackable
    if UnitCanAttack("player", unit) then
        nameplate.LvText:Show()
        nameplate.LevelText:Show()
    else
        nameplate.LvText:Hide()
        nameplate.LevelText:Hide()
    end
end

-- Function to create a custom nameplate (basic template)
local function CreateCustomNameplate(unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if nameplate then
        -- Create and customize health bar
        if not nameplate.HealthBar then
            nameplate.HealthBar = CreateFrame("StatusBar", nil, nameplate)
            nameplate.HealthBar:SetStatusBarTexture("Interface\\FFXIVUI\\HostileHPBar.tga")
            nameplate.HealthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            nameplate.HealthBar:SetValue(UnitHealth(unit))
            nameplate.HealthBar:SetPoint("CENTER", nameplate, "CENTER", 0, -10)
        end
        
        -- Update health
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        nameplate.HealthBar:SetMinMaxValues(0, maxHealth)
        nameplate.HealthBar:SetValue(health)

        -- Hide health bar if health is full
        if health == maxHealth then
            nameplate.HealthBar:Hide()
        else
            nameplate.HealthBar:Show()
        end

        -- Set nameplate text
        if not nameplate.NameText then
            nameplate.NameText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameplate.NameText:SetPoint("CENTER", nameplate, "CENTER", 0, 10)
        end

        nameplate.NameText:SetText(UnitName(unit))

        -- Update nameplate based on reaction
        UpdateNameplateColorAndTexture(unit, nameplate)
    end
end


-- Register event to trigger when nameplate is added
ffxivNameplatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
ffxivNameplatesFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "NAME_PLATE_UNIT_ADDED" then
        CreateCustomNameplate(arg1)
    end
end)


-- Event handler function to update nameplates dynamically
local function OnEvent(self, event, arg1, arg2)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        -- These events might not have a unit associated, so we skip processing here.
        -- If you need to check something globally, you can use "player" instead.
        local nameplate = C_NamePlate.GetNamePlateForUnit("player")
        if nameplate then
            UpdateNameplateColorAndTexture("player", nameplate)
        end
    elseif event == "UNIT_COMBAT" or event == "UNIT_NAME_UPDATE" then
        -- Ensure there's a valid unit argument for these events
        local unit = arg1
        if unit then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate then
                UpdateNameplateColorAndTexture(unit, nameplate)
            end
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        -- Create a custom nameplate for the new unit
        CreateCustomNameplate(arg1)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        -- Handle cleanup if necessary
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local unit = arg1
        if unit then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate and nameplate.HealthBar then
                local health = UnitHealth(unit)
                local maxHealth = UnitHealthMax(unit)
                nameplate.HealthBar:SetMinMaxValues(0, maxHealth)
                nameplate.HealthBar:SetValue(health)
            end
        end
    end
end


-- Create an event frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UNIT_COMBAT")
frame:SetScript("OnEvent", OnEvent)


-- Function to get the player's title without repeating the name
local function GetPlayerFullTitle(unit)
    if UnitIsPlayer(unit) then
        local title = UnitPVPName(unit) or ""  -- Get the player's title (if any)
        return title  -- Return only the title without the name
    else
        return nil  -- Return nil for non-players
    end
end

-- Function to get the player's guild name (if they belong to a guild)
local function GetPlayerGuild(unit)
    if UnitIsPlayer(unit) then
        local guildName = GetGuildInfo(unit)
        if guildName then
            return "<" .. guildName .. ">"  -- Adding < and > around the guild name
        else
            return ""  -- If no guild, return empty string
        end
    else
        return ""  -- No guild for NPCs
    end
end

-- Function to update the visibility of the guild name based on combat status and unit type
local function UpdateGuildVisibility(nameplate, unit)
    if UnitAffectingCombat(unit) then
        -- Hide guild name if the player is in combat
        if nameplate.GuildText then
            nameplate.GuildText:Hide()
        end
    else
        -- Show guild name if the player is not in combat and it's a player unit
        if nameplate.GuildText and UnitIsPlayer(unit) then
            nameplate.GuildText:Show()
        end
    end
end

-- Modify the CreateCustomNameplate function to hide guild name for NPCs
local function CreateCustomNameplate(unit)
    -- Get the nameplate for the unit
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)

    if nameplate then
        -- Create the name FontString (for player name)
        if not nameplate.NameText then
            nameplate.NameText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameplate.NameText:SetPoint("CENTER", nameplate, "CENTER", 0, 10)  -- Adjust vertically by 10 units
            local fontPath = "Interface\\AddOns\\SharedMedia_MyMedia\\font\\AxisRegular.ttf"
            nameplate.NameText:SetFont(fontPath, 10, "BOLD")  -- Set text to bold without outline
            nameplate.NameText:SetJustifyH("CENTER")  -- Center the text horizontally
            nameplate.NameText:SetShadowOffset(1, -1)  -- Add a shadow for readability
            nameplate.NameText:SetShadowColor(0, 0, 0, 1)  -- Set the shadow color to black
        end

        -- Create the guild FontString (for players only)
        if not nameplate.GuildText then
            nameplate.GuildText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameplate.GuildText:SetPoint("TOP", nameplate.NameText, "BOTTOM", 0, -2)  -- Position below the name (adjust vertical spacing)
            nameplate.GuildText:SetFont(nameplate.NameText:GetFont())  -- Inherit the same font as NameText
            nameplate.GuildText:SetFontObject(nameplate.NameText:GetFontObject())  -- Inherit the same font object
            nameplate.GuildText:SetJustifyH("CENTER")  -- Center the text horizontally
            nameplate.GuildText:SetShadowOffset(1, -1)  -- Same shadow as NameText
            nameplate.GuildText:SetShadowColor(0, 0, 0, 1)  -- Same shadow color as NameText
        end

        -- Set guild text color to match the player's name color
        nameplate.GuildText:SetTextColor(nameplate.NameText:GetTextColor())  -- Set the color of the guild text to match player name color

        -- Create the level FontString
        if not nameplate.LevelText then
            nameplate.LevelText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameplate.LevelText:SetPoint("RIGHT", nameplate.NameText, "LEFT", -5, -1)  -- Adjusted for alignment
            local levelFontPath = "Interface\\AddOns\\SharedMedia_MyMedia\\font\\EurostileExtendedBlack.ttf"
            nameplate.LevelText:SetFont(levelFontPath, 10, "BOLD")  -- Set text to bold without outline
            nameplate.LevelText:SetJustifyH("RIGHT")  -- Left justify the text
        end

        -- Create the "Lv" FontString for the level label
        if not nameplate.LvText then
            nameplate.LvText = nameplate:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameplate.LvText:SetPoint("RIGHT", nameplate.LevelText, "LEFT", 0, 1)  -- Move vertically by 10 units
            local lvFontPath = "Interface\\AddOns\\SharedMedia_MyMedia\\font\\EurostileBold.ttf"
            nameplate.LvText:SetFont(lvFontPath, 9, "BOLD")  -- Set text to bold without outline
            nameplate.LvText:SetJustifyH("RIGHT")  -- Left justify the text
        end

        -- Create the health bar beneath the nameplate, centered
        if not nameplate.HealthBarBackground then
            nameplate.HealthBarBackground = CreateFrame("Frame", nil, nameplate, "BackdropTemplate")
            nameplate.HealthBarBackground:SetPoint("TOP", nameplate, "BOTTOM", 0, 57)  -- Position beneath the nameplate
            local originalWidth = 75
            local originalHeight = 75
            local scaleFactor = 1.2  -- 120%
            nameplate.HealthBarBackground:SetWidth(originalWidth * scaleFactor)
            nameplate.HealthBarBackground:SetHeight(originalHeight * scaleFactor)
            nameplate.HealthBarBackground:SetBackdrop({
                bgFile = "Interface\\FFXIVUI\\HostileHPBackdrop.tga",  -- Custom background texture
                insets = {left = 2, right = 2, top = 2, bottom = 2}  -- Insets for inner spacing
            })
            nameplate.HealthBarBackground:SetBackdropColor(0, 0, 0, 0.5)  -- Dark background for the health bar
        end

        if not nameplate.HealthBar then
            nameplate.HealthBar = CreateFrame("StatusBar", nil, nameplate.HealthBarBackground)
            nameplate.HealthBar:SetStatusBarTexture("Interface\\FFXIVUI\\HostileHPBar.tga")  -- Custom health bar texture
            
            -- Set the width and height of the health bar manually
            local healthBarWidth = nameplate.HealthBarBackground:GetWidth() * .88  -- 88% of the background's width
            local healthBarHeight = nameplate.HealthBarBackground:GetHeight() * .80  -- 85% of the background's height

            -- Set the position of the health bar relative to the background
            local xOffset = 0  -- Horizontal offset (relative to the background)
            local yOffset = 0  -- Vertical offset (relative to the background)

            -- Set the health bar's size and position manually
            nameplate.HealthBar:SetWidth(healthBarWidth)
            nameplate.HealthBar:SetHeight(healthBarHeight)
            nameplate.HealthBar:SetPoint("CENTER", nameplate.HealthBarBackground, "CENTER", xOffset, yOffset)  -- Center the health bar within the background
            
            -- Set the texture coordinates (crop 18 pixels on each side)
            local tex = nameplate.HealthBar:GetStatusBarTexture()
            tex:SetTexCoord(0, 1, 0, 1)  -- Crop 18 pixels on each side
        end

        -- Update health bar
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)

        nameplate.HealthBar:SetMinMaxValues(0, maxHealth)
        nameplate.HealthBar:SetValue(health)

        -- Get player's title and guild name (if the unit is a player)
        local title = GetPlayerFullTitle(unit)
        local guild = GetPlayerGuild(unit)

        -- Update nameplate text
        if title and title ~= "" then
            -- Display the player's title
            nameplate.NameText:SetText(title)
            if guild and guild ~= "" then
                -- Display the guild name below the title
                nameplate.GuildText:SetText(guild)
                nameplate.GuildText:Show()
            else
                nameplate.GuildText:Hide()  -- Hide guild name if no guild is present
            end
        else
            -- Display NPC name (if the unit is not a player)
            nameplate.NameText:SetText(UnitName(unit))
            nameplate.GuildText:Hide()  -- Hide guild name for NPCs
        end

        nameplate.LvText:SetText("Lv")
        nameplate.LevelText:SetText(UnitLevel(unit))

        -- Update nameplate color and textures
        UpdateNameplateColorAndTexture(unit, nameplate)

        -- Show the health bar and texts only if unit is in combat
        if UnitAffectingCombat(unit) then
            nameplate.HealthBar:Show()
            nameplate.HealthBarBackground:Show()
        else
            nameplate.HealthBar:Hide()
            nameplate.HealthBarBackground:Hide()
        end

        -- Show the name text
        nameplate.NameText:Show()

        -- Update the guild visibility based on combat status
        UpdateGuildVisibility(nameplate, unit)
    end
end

ffxivNameplatesFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
ffxivNameplatesFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
ffxivNameplatesFrame:RegisterEvent("UNIT_HEALTH")
ffxivNameplatesFrame:RegisterEvent("UNIT_MAXHEALTH")
ffxivNameplatesFrame:RegisterEvent("UNIT_COMBAT")
ffxivNameplatesFrame:RegisterEvent("UNIT_NAME_UPDATE")  -- Add this event

ffxivNameplatesFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        -- Create a custom nameplate for the new unit
        CreateCustomNameplate(unit)
    elseif event == "UNIT_NAME_UPDATE" then
        -- Update nameplate name after the unit's name is fully loaded
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplate and nameplate.NameText then
            nameplate.NameText:SetText(UnitName(unit))  -- Ensure name is updated
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        -- Update health bar when health changes
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplate and nameplate.HealthBar then
            local health = UnitHealth(unit)
            local maxHealth = UnitHealthMax(unit)
            nameplate.HealthBar:SetMinMaxValues(0, maxHealth)
            nameplate.HealthBar:SetValue(health)
        end
    elseif event == "UNIT_COMBAT" then
        -- Show or hide health bar based on combat status
        local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplate then
            if UnitAffectingCombat(unit) then
                nameplate.HealthBar:Show()
                nameplate.HealthBarBackground:Show()
            else
                nameplate.HealthBar:Hide()
                nameplate.HealthBarBackground:Hide()
            end
            -- Update the guild visibility based on combat status
            UpdateGuildVisibility(nameplate, unit)
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        -- Cleanup if needed when the unit is removed
    end
end)

