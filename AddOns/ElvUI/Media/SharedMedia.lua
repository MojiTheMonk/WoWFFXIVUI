local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local LSM = E.Libs.LSM

E.Media = {
	Fonts = {},
	Sounds = {},
	ChatEmojis = {},
	ChatLogos = {},
	Textures = {}
}

local format = format
local ipairs, type = ipairs, type
local westAndRU = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western

do
	local t, d = '|T%s%s|t', ''
	function E:TextureString(texture, data)
		return format(t, texture, data or d)
	end
end

local MediaKey = {
	font	= 'Fonts',
	sound	= 'Sounds',
	emoji	= 'ChatEmojis',
	logo	= 'ChatLogos',
	texture	= 'Textures'
}

local MediaPath = {
	font	= [[Interface\AddOns\ElvUI\Media\Fonts\]],
	sound	= [[Interface\AddOns\ElvUI\Media\Sounds\]],
	emoji	= [[Interface\AddOns\ElvUI\Media\ChatEmojis\]],
	logo	= [[Interface\AddOns\ElvUI\Media\ChatLogos\]],
	texture	= [[Interface\AddOns\ElvUI\Media\Textures\]]
}

local function AddMedia(Type, File, Name, CustomType, Mask)
	local path = MediaPath[Type]
	if path then
		local key = File:gsub('%.%w-$','')
		local file = path .. File

		local pathKey = MediaKey[Type]
		if pathKey then E.Media[pathKey][key] = file end

		if Name then -- Register to LSM
			local nameKey = (Name == true and key) or Name
			if type(CustomType) == 'table' then
				for _, name in ipairs(CustomType) do
					LSM:Register(name, nameKey, file, Mask)
				end
			else
				LSM:Register(CustomType or Type, nameKey, file, Mask)
			end
		end
	end
end

-- Name as true will add the Key as it's name
AddMedia('font','ActionMan.ttf',			'Action Man')
AddMedia('font','ContinuumMedium.ttf',		'Continuum Medium')
AddMedia('font','DieDieDie.ttf',			'Die Die Die!')
AddMedia('font','PTSansNarrow.ttf',			'PT Sans Narrow', nil, westAndRU)
AddMedia('font','Expressway.ttf',			true, nil, westAndRU)
AddMedia('font','Homespun.ttf',				true, nil, westAndRU)
AddMedia('font','Invisible.ttf')

AddMedia('sound','AwwCrap.ogg',					'Awww Crap')
AddMedia('sound','BbqAss.ogg',					'BBQ Ass')
AddMedia('sound','DumbShit.ogg',				'Dumb Shit')
AddMedia('sound','MamaWeekends.ogg',			'Mama Weekends')
AddMedia('sound','RunFast.ogg',					'Runaway Fast')
AddMedia('sound','StopRunningSlimeBall.ogg',	'Stop Running')
AddMedia('sound','Whisper.ogg',					'Whisper Alert')
AddMedia('sound','YankieBangBang.ogg',			'Big Yankie Devil')
AddMedia('sound','HelloKitty.ogg')
AddMedia('sound','HarlemShake.ogg')

AddMedia('texture','GlowTex',		'ElvUI GlowBorder', 'border')
AddMedia('texture','NormTex',		'ElvUI Gloss',	'statusbar')
AddMedia('texture','NormTex2',		'ElvUI Norm',	'statusbar')
AddMedia('texture','White8x8',		'ElvUI Blank', {'statusbar','background'})
AddMedia('texture','Minimalist',	true, 'statusbar')
AddMedia('texture','Melli',			true, 'statusbar')

AddMedia('texture','Arrow')
AddMedia('texture','ArrowRight')
AddMedia('texture','ArrowUp')
AddMedia('texture','Arrow1')
AddMedia('texture','Arrow2')
AddMedia('texture','BagNewItemGlow')
AddMedia('texture','BagQuestIcon')
AddMedia('texture','BagUpgradeIcon')
AddMedia('texture','Black8x8')
AddMedia('texture','BubbleTex')
AddMedia('texture','ChatEmojis')
AddMedia('texture','ChatLogos')
AddMedia('texture','Close')
AddMedia('texture','Combat')
AddMedia('texture','Copy')
AddMedia('texture','Cross')
AddMedia('texture','DPS')
AddMedia('texture','ExitVehicle')
AddMedia('texture','Healer')
AddMedia('texture','HelloKitty')
AddMedia('texture','HelloKittyChat')
AddMedia('texture','Help')
AddMedia('texture','Highlight')
AddMedia('texture','LeaderHQ')
AddMedia('texture','LogoTop')
AddMedia('texture','LogoTopSmall')
AddMedia('texture','LogoBottom')
AddMedia('texture','LogoBottomSmall')
AddMedia('texture','Mail')
AddMedia('texture','Minus')
AddMedia('texture','MinusButton')
AddMedia('texture','Pause')
AddMedia('texture','PhaseIcons')
AddMedia('texture','Play')
AddMedia('texture','Plus')
AddMedia('texture','PlusButton')
AddMedia('texture','Reset')
AddMedia('texture','Resting')
AddMedia('texture','Resting1')
AddMedia('texture','RolesHQ')
AddMedia('texture','RoleIcons')
AddMedia('texture','SkullIcon')
AddMedia('texture','Smooth')
AddMedia('texture','Spark')
AddMedia('texture','Tank')
AddMedia('texture','TukuiLogo')

AddMedia('emoji','Angry')
AddMedia('emoji','Blush')
AddMedia('emoji','BrokenHeart')
AddMedia('emoji','CallMe')
AddMedia('emoji','Cry')
AddMedia('emoji','Facepalm')
AddMedia('emoji','Grin')
AddMedia('emoji','Heart')
AddMedia('emoji','HeartEyes')
AddMedia('emoji','Joy')
AddMedia('emoji','Kappa')
AddMedia('emoji','Meaw')
AddMedia('emoji','MiddleFinger')
AddMedia('emoji','Murloc')
AddMedia('emoji','OkHand')
AddMedia('emoji','OpenMouth')
AddMedia('emoji','Poop')
AddMedia('emoji','Rage')
AddMedia('emoji','SadKitty')
AddMedia('emoji','Scream')
AddMedia('emoji','ScreamCat')
AddMedia('emoji','SemiColon')
AddMedia('emoji','SlightFrown')
AddMedia('emoji','Smile')
AddMedia('emoji','Smirk')
AddMedia('emoji','Sob')
AddMedia('emoji','StuckOutTongue')
AddMedia('emoji','StuckOutTongueClosedEyes')
AddMedia('emoji','Sunglasses')
AddMedia('emoji','Thinking')
AddMedia('emoji','ThumbsUp')
AddMedia('emoji','Wink')
AddMedia('emoji','ZZZ')

AddMedia('logo','ElvRainbow')
AddMedia('logo','ElvSimpy')
AddMedia('logo','ElvBlue')
AddMedia('logo','ElvGreen')
AddMedia('logo','ElvOrange')
AddMedia('logo','ElvPink')
AddMedia('logo','ElvPurple')
AddMedia('logo','ElvYellow')
AddMedia('logo','ElvRed')
AddMedia('logo','Bathrobe')
AddMedia('logo','HelloKitty')
AddMedia('logo','Illuminati')
AddMedia('logo','MrHankey')
AddMedia('logo','Rainbow')
AddMedia('logo','TyroneBiggums')
AddMedia('logo','Burger')
AddMedia('logo','Clover')
AddMedia('logo','Cupcake')
AddMedia('logo','Hibiscus')
AddMedia('logo','Lion')
AddMedia('logo','Skull')
AddMedia('logo','Unicorn')
AddMedia('logo','FoxDeathKnight')
AddMedia('logo','FoxDemonHunter')
AddMedia('logo','FoxDruid')
AddMedia('logo','FoxHunter')
AddMedia('logo','FoxMage')
AddMedia('logo','FoxMonk')
AddMedia('logo','FoxPaladin')
AddMedia('logo','FoxPriest')
AddMedia('logo','FoxRogue')
AddMedia('logo','FoxShaman')
AddMedia('logo','FoxWarlock')
AddMedia('logo','FoxWarrior')
AddMedia('logo','DeathlyHallows')
AddMedia('logo','GoldShield')
AddMedia('logo','Gem')

LSM:Register("font","EurostileBold", [[Interface\AddOns\ElvUI\media\fonts\EurostileBold.ttf]]) 
LSM:Register("font","EurostileExtended", [[Interface\AddOns\ElvUI\media\fonts\EurostileExtended.ttf]])
LSM:Register("font","EurostileExtendedBlack", [[Interface\AddOns\ElvUI\media\fonts\EurostileExtendedBlack.ttf]])
LSM:Register("font","EurostileOblique", [[Interface\AddOns\ElvUI\media\fonts\EurostileOblique.ttf]])
LSM:Register("font","EuroStyle Normal", [[Interface\AddOns\ElvUI\media\fonts\EuroStyle Normal.ttf]]) 
LSM:Register("font","AxisExtrabold", [[Interface\AddOns\ElvUI\media\fonts\AxisExtrabold.otf]]) 
LSM:Register("font","MavenPro-VariableFont_wght", [[Interface\AddOns\ElvUI\media\fonts\MavenPro-VariableFont_wght.ttf]]) 
LSM:Register("font","MavenPro-Regular", [[Interface\AddOns\ElvUI\media\fonts\MavenPro-Regular.ttf]]) 
LSM:Register("font","MavenPro-Medium", [[Interface\AddOns\ElvUI\media\fonts\MavenPro-Medium.ttf]]) 
LSM:Register("font","MavenPro-Bold", [[Interface\AddOns\ElvUI\media\fonts\MavenPro-VariableFont_wght.ttf]]) 
LSM:Register("font","MavenPro-Black", [[Interface\AddOns\ElvUI\media\fonts\MavenPro-Black.ttf]])
LSM:Register("font","axis", [[Interface\AddOns\ElvUI\media\fonts\axis.otf]])
LSM:Register("font","AxisMedium", [[Interface\AddOns\ElvUI\media\fonts\AxisMedium.ttf]]) 
LSM:Register("font","AxisRegular", [[Interface\AddOns\ElvUI\media\fonts\AxisRegular.ttf]]) 
LSM:Register("font","MiedingerMedium", [[Interface\AddOns\ElvUI\media\fonts\MiedingerMedium.ttf]]) 
LSM:Register("font","LeviReBrushed", [[Interface\AddOns\ElvUI\media\fonts\LeviReBrushed.ttf]]) 