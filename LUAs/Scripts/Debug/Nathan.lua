require "Debug\\SpawnInFrontOfPlayer"
require "State\\Team\\Character\\StreetSoldierTeam"
require "State\\NPC\\Character\\StreetSoldier"

local tAiManager = cAiManager.RetAiManager ()
local tPlayer = tAiManager:RetPlayer (0)

if false then

	local tTeam = cTeamManager.CreateTeam ("NathansTeam", tMuchachos, true)
	
	for i=1, 3 do
	
		local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier2", nil, 5+(3*i))
	
		tNPC:AddEquipment ("M16")
		tNPC:AddEquipment ("Grenade")
	
		tTeam:AddEntity (tNPC)
	
	end
	
	tTeam:SetState (StreetSoldierTeam)

end

if false then

	local tTeam = cTeamManager.RetTeamWithName ("NathansTeam")
	AILib.Emit (tTeam:RetDebugString ())

end

if false then

	tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier2", nil, 10)
	--tProp = SpawnInFrontOfPlayer ("PROP_Cone_001", 20)
	
	--local tNPC = cAIPlayer.SpawnNPCAtNamedLocation ("AIStreetSoldier2", "SP_HH_BodyGuard3")
	
	tNPC:AddEquipment ("Riley_Panther")
	tNPC:AddEquipment ("RocketLauncher")
--	tNPC:AddEquipment ("Grenade")
	tNPC:SetViewingDistance (100)
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nNormal)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)
	tNPC:SetState (StreetSoldier)

end

if false then

	local tNPC = tAiManager:RetAiPlayerByName ("Barwise")
	Emit (tNPC:RetDebugString ())

end

NavigationManager.SetStreetEnabled (tPlayer:RetPosition (), false)
