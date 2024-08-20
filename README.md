# Crackdown 1 & 2 Xbox 360 Documentation 📜
## Table of Contents
- [Crackdown](#Crackdown)
- [Crackdown 2](#Crackdown2)
- [Extra](#Extra)

# Everything you find here is for the latest update for retail versions of both games!

## Crackdown:

Addresses to check in IDA / Ghidra / PeekPoker

82AE69D8 - possibly where the game checks if the debug menu should be activated

8325DFB8 - possibly the offset for checking if console command should be sent in offline/online state.


# New list of working console commands for Crackdown:
luafile - Executes a lua script filescript | luafile %s%S | luafile D:\\Scripts\\%s*.lua

bind - bind command to button | Example: bind 1 "allskills 1"

spdup

spddn

dpgoto Scheduler

nextchar

prevchar

nextvehicle

prevvehicle

resetmetrics

dan

fly

suicide

flymode

crcam

fpcam

reloadshaders

fps

helicam

forceintovehicle

allskills 1

allskills 2

allskills 3

allskills 4

allskills 5

loaded

god

posinfo

ToggleShortKeys

hud

screencapture

startmc

resetpeaks

growtimertree

stopmc

lastcmd

todsetphase 0.25 - set any number to change time of day

togglebloom - toggle bloom on and off

toggleafterlights - toggle lights after dark

togglevehiclelights - toggle vehicle lights

toggleshadows - toggle shadows

toggleoutlines - toggle outlines

ToggleTactileFeedback - toggle controller vibrations from gunfire, etc.



## Crackdown2:

# Offsets
0x82771EB0 - ConsoleCommand

# New list of working console commands for Crackdown 2:
# Debug Stuff
toggledebuginput - Toggle Debug Input for Final

minp - Binds input key(s) to an action | example: minp press VK_XENON_DPAD_U "cheat_menu_up" | minp [action] [button] ["command"]

bind - bind command to button | Example: bind 1 "allskills 1"

# Misc

test_deity_ray - Create test deity ray effect

kill_deity_ray - Terminate test deity ray effect

pause - Pauses game logic

togglemotionblur - Toggle motion blur

toggleparticlealpha

widescreen - Toggles aspect between 4:3 and 16:9

toggleHUD - Toggles HUD on / off

DisableMiniGames - Disables mini-game scripts. Must be set in userstartup to take effect

toggleConference - Toggles Conference config

togglelicensesetting - Toggles all dlc license setting free / paid

toggledlcloadiffound - Toggles whether we load DLC if found or not

togglelicenseoverride - Toggles all dlc license override on / off

purchase_dlc - Simulates purchase of a DLC offer

ignore_dlc_resources - Ignores checks for available resources when activating DLC

showstunttext - Show stunt completion text. Args: [stunt type] [current] [total]

summon - summon NAMEOFITEM

toggleorbs - Toggles agility/hidden orbs

apocalypse - Kill all bots (player takes credit)

setonfire - Sets the players target on fire

rain - Sets it to rain around the player

instagib - Instantly kills player's target

combust - The target combusts

StunAllCharacters - Stun all the AI characters in the volume.

deleteallweapons - Delete all weapons that the AI have.

ui_showallorbs - Shows all orbs on the UI map screen

ui_showalllogs - Shows all logs on the UI map screen

showlpt - Toggles launch pad trajectory rendering

setscaler - setscaler NAME # | <NAME> <#> - Sets the named performance scaler to the specified value

driving_turbo - Use vehicle turbo



# Lua & Scripting
D:\\Scripts\\%S* .lua

lua - Executes a chunk of lua script.script

luafile - Executes a lua script filescript | luafile %s%S | luafile D:\\Scripts\\%s*.lua

emitluacalls - Emits whenever Lua is called

emitluafileaccess - Turns on/off lua file access emits

preprocessscripts - Turns on/off preprocessing of lua scripts

script

ScriptDebuggerOn - Decides whether ScriptDebugger should be run

editscripts - Toggles / sets whether scripts will be loaded individually off disk. Must be set in userstartup to take effect



# Gamemode Stuff
completewave - Complete Current Wave immediately

TogglePBM - Toggle points based multiplier rather than combo based.

givesunburstpowerup - Give sunburst power up. (givesunburstpowerup 1 Infinite Fuel | 2 Time Extend | 3 Max Health Armour | 4 Quad Damage | 5 Stealth | 6 Infinite Ammo | 7 Invulnerability | 9 Random | 10 Linear)"



# Player Stuff
god - Toggles player character invulnerable to damage

infiniteammo - Give player infinite ammo

loaded - Gives the player all available equipment

addweapon - Gives the player a specified weapon | example: addweapon "WEPGEN06_Glauncher"

transformplayer - tests transform vfx

pingnearbyorbs - Pings nearby orbs, within radius specified

scaleplayer - scales the player

scalechar - Scales the player's target (if it's a character)

togglespawn - Toggles spawn points active and inactive

apocalypse - Kill all bots (player takes credit)

allskills

maxagentskills

unlock_supply_points

forceunlocksupplypoints - Unlocks all supply points

squadbonus

fightingbonus

firearmbonus

explosivebonus

athleticbonus

decallskills

decfightingskill

decexplosiveskill

decdrivingskill

incallskills

incfightingskill

incfirearmskill

incexplosiveskill

incdrivingskill

incathleticskill

firearmskill

explosiveskill

athleticskill



# Lobby & Matchmaking
maxplayers - Set max players (maxplayers 18)

setminplayers - Set minimum players needed to access a public game

toggleAllowForceHost - Toggles whether the force host option is available

sethostprobability - Sets up hosting probabilities for Quick Match. Args [active 0/1] [probability start 0-1] [probability scale] [max searches]

forceshowbadconnectionhud - Forces the Bad connection HUD to display

toggletargetlag - Set target to lag

ignorenetworkdisconnects - Toggle handling of network disconnects.


# Weather & Enviroment
forcelod - forcelod #

forceskytod - Forces sky time of day

disableforceskytod - Stop forcing sky TOD

todfup

tode3setphase - Set the time of day, setting shadows as appropriate for the E3 build. Phase is same as todsetphase, but the value will be clamped to one of the valid E3 settings

tode3advance

togglelod4env - Toggles or specifically sets drawing of LOD4 environment

todsetrandomphase - Select a random time of day

todsetperiod - Set the time of day period (mins IRL)

todtoggle - TimeOfDay

toggletoddoors - Enables/disables time-of-day door controlprops

toggle_dof - Toggle DOF effect

toggleopaquepass - Toggle the opaque render pass

togglealphapass - Toggle the alpha render pass

toggleoutlines - Toggle the rendering of outlines

togglewaterpass - Toggle the water render pass


# Weapons
MP_WEPGEN03_Demp90A

WEPGEN11_SticklerGrenade

WEPGEN04_MachHMG120

WEPGEN06_Glauncher

WEPGEN07_RLauncher

WEPGEN08_HRlauncher

WEPGEN05_SniperSX1A

MP_WEPGEN03_Demp90A_Bullet

MP_WEPGEN04_MachHMG120

MP_WEPGEN07_RLauncher

WEPGEN07_RLauncher_Proj

MP_WEPGEN02_IngallsAL107

MP_WEPGEN01_IngallsXGS

MP_WEPGEN05_SniperSX1A

WEPGEN07_Rlauncher

WEPGEN03_Demp90A

WEPGEN02_IngallsAL107

WEPGEN01_IngallsXGS

WEPGEN10_ClusterGrenade

WEPGEN10_Grenade

WEPGEN10_ShrapnelGrenade

MP_WEPAGY15_UVShotgun

MP_WEPAGY05_Sniper

MP_WEPAGY05_AMSniper

MP_WEPAGY04_MachGun

MP_WEPAGY03_UltraShotgun

MP_WEPAGY02_UltraAssault

MP_WEPAGY02_Assault

MP_WEPAGY01_UltraSMG

MP_WEPAGY03_Shotgun

WEPAGY05_AMSniper

WEPAGY05_Sniper

WEPAGY10_LimpetCharge

WEPAGY10_ProxMine

WEPAGY15_UVShotgun

WEPAGY04_MachGun

WEPAGY03_UltraShotgun

WEPAGY03_Shotgun

WEPAGY02_UltraAssault

WEPAGY02_Assault

WEPAGY01_UltraSMG

WEPAGY01_SMG

WEPAGY10_PekingDuck

WEPAGY06_Flocket

WEPAGY15_UVGrenade

WEPTUR11_TagLauncher

WEPTUR06_BreachRocket

WEPTUR01_MachGun

WEPTUR02_Flocket

WEPTUR03_Flack

WEPTUR04_Laser

WEPTUR05_UV

WEPTUR11_TAGLAUNCHER

WEPTUR03_Flack_Barrel

WEPTUR01_MachGun_Barrell

WEPTUR03_FLACK

WEPTUR02_FLOCKET

WEPTUR01_MACHGUN

WEPFRK12_GoliathRockBomb

WEPFRK10_AcidClusterBomb

WEPGAD10_BoostPack

WEPGAD11_PortableLaunchPad

WEPGAD03_Mags

WEPGAD01_Harpoon_BoltRender

WEPGAD01_Harpoon


# Items
PRPGL001_Duck

PRPGL018_Commuter

PRPGL018_DeliveryVan

PRPGL048_Box_M_Card

PRPGL048_Box_S_Card

PRPGL002_Beachball

PRPGL003_Golfball

PRPGL009_Boulder_Large

PRPGL009_Boulder_Med

PPRPGL009_Goliath_Boulder

PRPGL010_ConcBarricade_Ex1

PPRPGL010_ConcBarricade_Ex1_02

PPRPGL010_ConcBarricade_Ex2

PPRPGL010_ConcBarricade_Ex2_02

PRPGL016_ShopTrolley

PRPGL060_SatDish_Small

PRPGL070_Cell_I_Ex1

PRPGL010_ConcPiller_01

PRPGL012_PickAxe

PRPGL012_Scaffold_Plank

PRPGL012_Scaffold_Pole

PRPGL025_PalletWoodCombat

PRPGL030_Bench_WoodCombat

PRPGL053_Rufficlub

PRPGL018_Car_Axle

PRPGL047_Barrel

PRPGL047_GasCanister

PRPGL048_Box_Wood_Explosive

PRPGL025_PalletWood

PRPGL026_Refuse_Bag

PRPGL026_Refuse_BinDouble

PRPGL026_Refuse_BinSingle

PRPGL026_Trashcan

PRPGL030_Bench_Wood

PRPGL030_Bench_WoodDamage

PRPGL047_Barrel_Brazier

PRPGL051_PhoneBooth_LOD1

PRPGL040_Armchair

PRPGL040_BoomBox

PRPGL040_Chair_Wood_Orig

PRPGL040_Sofa

PRPAM002_FruitVeg_Crate

PRPAM001_FakeAnt_Crate

PRPAM002_FruitVeg_Crate_Closed

PRPAM001_FakeAnt_Sign

PRPAM002_FruitVeg_Board

PRPAM003_Safehouse_Sign_A

PRPAM004_UrbanS_Sign_A

PRPAM005_VehicleP_Board_A

PRPAM006_WeaponP_Board_A

PRPAM007_LightP_Board_A

PRPAM005_Banner_Ex1

PRPAM005_VehicleP_Banner

PRPAM001_FakeAnt_Banner

PRPAM006_WeaponP_Banner

PRPAM007_LightP_Board_Truck

PRPAM007_LightP_Sign_Pole

PRPAM007_LightP_Sign_Pole_Tall

PRPAM006_WeaponP_Sign_Pole

PRPAM005_VehicleP_Sign_Pole

PRPAM003_SafeHouse_Sign_Pole

PRPAM010_AVSystem

PRPAM012_Barbell

PRPAM013_Guitar

PRPAM009_Generator

PRPAM010_PastingTable

PRPAM010_Table

PRPMS010_Breech_Inactive

PRPMS003_PowerStation_Club

PRPMS012_Missile


# AI & Characters
AICHACEL01_BCellSmg

AICHACEL02_BCellRocket

AICHACEL03_BCellShotgun

AICHACEL04_BCellRifle

AICHACEL01_BCellFlare

AICHACEL01_BCellFlareNoGrenade

AICHACEL01_BCellSmgNoGrenade

AICHACEL01_BCellSmgShrapnelGrenade

AICHACEL01_BCellRoadWarrior

AICHACEL01_BCellRoadWarriorSMG

AICHACEL02_BCellRoadWarrior

AICHACEL01_BCellSmgMusician

AICHACEL02_BCellShotgun

AICHACEL02_BCellShotgun NoGrenade

AICHACEL02_BCellShotgun ShrapnelGrenade

AICHACEL02_BCellRoadWarriorShotgun

AICHACEL03_BCellGrenadeLauncher

AICHACEL03_BCellRoadWarriorGrenade

AICHACEL03_BCellSniper

AICHACEL04_BCellLMG

AICHACEL04_BCellRoadWarriorLMG

AICHACEL04_BCellRoadWarriorRifle

AICHACEL05_BCellHomingRocket

AICHACEL05_BCellRocket

AICHACEL06_BCellMinigun

AICHACIVGUARD01_BCivilGuard

AICHACIVGUARD01_BCivilNightGuard

AICHACIVGUARD02_BCivilGuard

AICHACIVGUARD02_BCivilNightGuard

AICHACIVGUARD03_BCivilGuard

AICHACIVGUARD03_BCivilNightGuard

AICHACIVGUARD04_BCivilGuard

AICHACIVGUARD04_BCivilNightGuard

AICHACIVGUARD05_BCivilGuard

AICHACIVGUARD05_BCivilNightGuard

AICHACIVGUARD06_BCivilGuard

AICHACIVGUARD06_BCivilNightGuard

AICHAPEA01_M_BPeacePKDrop

AICHAPEAM_BPeaceBeaconDrop

AICHAPEA01_M_BPeaceVehicleCollection

AICHAPEA01_M_BPeaceAgentPickup

AICHAPEA01_M_BPeacePilot

AICHAPEA01_M_BTrainingHeliPilot

AICHAPEA01_M_BPeaceEquipDrop

AICHAPEA02_BPeaceMale

AICHAPEA01_BPeaceDriveWanderAttack

AICHAPEA01_BPeacekeeperARPilot

AICHAPEA01_BPeaceAirwolf

AICHAPEA01_M_BPeaceMale

AICHAPEA01_F_BPeaceFemale

AICHAPEA01_BPeaceHighwayPatrol

AICHAPEA01_M_BPeaceMale2

AICHAPEA03_BPeaceMale

AICHAREA02_STR_L2_BReaperStr_L2

AICHAREA02_STR_L3_BReaperStr_L3

AICHAREA02_STR_L1_BReaperStr_L1

AICHAREA01_AGI_L3_BReaperAgi_L3

AICHAREA01_AGI_L2_BReaperAgi_L2

AICHAREA01_AGI_L1_BReaperAgi_L1

AICHAREA03_BReaperAgent

AICHAREA03_Midget_BReaperAgent

AICHAGOL01_BGoliath


# Vehicles
VEHCEL14_ArcticTruck

VEHCEL16_HeavyTruck

VEHCEL11_DeliveryVan

VEHCEL01_Roadster

VEHCEL02_Cabriolet

VEHCEL03_Coupe

VEHCEL04_MuscleCar

VEHCEL05_Saloon

VEHCEL06_Jcar

VEHCEL07_Pickup

VEHCEL08_Lowrider

VEHCEL09_SUV

VEHCEL10_6WSUV

VEHCEL12_Van

VEHCEL13_TowTruck

VEHCEL15_MilitaryTruck

VEHCEL17_APC

VEHCEL18_ABus

VEHCEL19_BBus

VEHCIV01_Estate

VEHCIV01_Roadster

VEHCIV03_Commuter_02

VEHCIV04_Saloon

VEHCIV05_DeliveryVan_01

VEHCIV06_DeliveryVan_02

VEHCIV07_Deliverytruck

VEHCIV08_RampTruck

VEHCIV02_Commuter_01

MP_VEHAGY03_Tank

MP_VEHAGY05_Buggy

VEHAGY01_Sportscar

VEHAGY02_SUV

VEHAGY03_Tank

VEHAGY05_Buggy

VEHAGY06_Helicopter

VEHAGY08_Peacecar

VEHAGY09_ATV

VEHAGY10_SquadChopper

Vehicle_ATV_NonPlayer

Vehicle_ATV_Player

Vehicle_Buggy_Player

Vehicle_Cell_Type01_NonPlayer

Vehicle_Cell_Type01_Player

Vehicle_Commuter01_NonPlayer

Vehicle_Commuter01_Player

Vehicle_Coupe_NonPlayer

Vehicle_Coupe_Player

Vehicle_DeliveryVan01_NonPlayer

Vehicle_DeliveryVan01_Player

Vehicle_DeliveryVan02_NonPlayer

Vehicle_DeliveryVan02_Player

Vehicle_Diesel_NonPlayer

Vehicle_Diesel_Player

Vehicle_Estate_NonPlayer

Vehicle_Estate_Player

Vehicle_Estate02_NonPlayer

Vehicle_Estate02_Player

Vehicle_Jcar_NonPlayer

Vehicle_Jcar_Player

Vehicle_Peacecar_NonPlayer

Vehicle_Peacecar_Player

Vehicle_Pickup_NonPlayer

Vehicle_Pickup_Player

Vehicle_Saloon_NonPlayer

Vehicle_Saloon_Player

Vehicle_Sportscar_NonPlayer

Vehicle_SUV_NonPlayer

Vehicle_Tank_NonPlayer

## Extra
# Button Names & Mapping
# Xbox 360 Controller:
VK_XENON_DPAD_U

VK_XENON_DPAD_D

VK_XENON_DPAD_L

VK_XENON_DPAD_R

VK_XENON_START

VK_XENON_BACK

VK_XENON_LTHUMB_BUTTON

VK_XENON_RTHUMB_BUTTON

VK_XENON_LSHOULDER

VK_XENON_RSHOULDER

VK_XENON_A

VK_XENON_B

VK_XENON_X

VK_XENON_Y

VK_XENON_LTRIGGER

VK_XENON_RTRIGGER

VK_XENON_LTHUMB_X

VK_XENON_LTHUMB_Y

VK_XENON_RTHUMB_X

VK_XENON_RTHUMB_Y

# Keyboard & Mouse:
VK_UNASSIGNED

VK_LBUTTON

VK_RBUTTON

VK_CANCEL

VK_MBUTTON

VK_XBUTTON1

VK_XBUTTON2

VK_BACK

VK_TAB

VK_CLEAR

VK_RETURN

VK_SHIFT

VK_CONTROL

VK_MENU

VK_PAUSE

VK_CAPITAL

VK_KANA

VK_HANGUL

VK_JUNJA

VK_FINAL

VK_HANJA

VK_KANJI

VK_ESCAPE

VK_CONVERT

VK_NONCONVERT

VK_ACCEPT

VK_MODECHANGE

VK_SPACE

VK_PRIOR

VK_NEXT

VK_END

VK_HOME

VK_LEFT

VK_UP

VK_RIGHT

VK_DOWN

VK_SELECT

VK_PRINT

VK_EXECUTE

VK_SNAPSHOT

VK_INSERT

VK_DELETE

VK_HELP

VK_LWIN

VK_RWIN

VK_APPS

VK_SLEEP

VK_NUMPAD0

VK_NUMPAD1

VK_NUMPAD2

VK_NUMPAD3

VK_NUMPAD4

VK_NUMPAD5

VK_NUMPAD6

VK_NUMPAD7

VK_NUMPAD8

VK_NUMPAD9

VK_MULTIPLY

VK_ADD

VK_SEPARATOR

VK_SUBTRACT

VK_DECIMAL

VK_DIVIDE

VK_F1

VK_F2

VK_F3

VK_F4

VK_F5

VK_F6

VK_F7

VK_F8

VK_F9

VK_F10

VK_F11

VK_F12

VK_F13

VK_F14

VK_F15

VK_F16

VK_PAD_A

VK_PAD_B

VK_PAD_X

VK_PAD_Y

# Minp Functionality

Actions:

heldless

heldstate

state

press

threshless

threshgreater

Example:
minp heldless  0.30 VK_XENON_Y "character_entervehicle"

minp heldstate 0.30 VK_XENON_Y "character_activatecamcut"

minp state VK_XENON_B "driving_horn"

minp press VK_XENON_B "driving_togglesiren"

