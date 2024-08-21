require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Character\\StreetSoldier"

local tNPC1 = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
local tNPC2 = SpawnNPCInFrontOfPlayer ("AIStreetSoldier2", nil, 25)

tNPC1:SetTeamSide (tMuchachos)
tNPC2:SetTeamSide (tMob)

--local tAiManager = cAiManager.RetAiManager ()
--local tPlayer = tAiManager:RetPlayer (0)

tNPC1:SetState (Create (StreetSoldier,
{
	tEnemy = tNPC2,
}))

tNPC2:SetState (Create (StreetSoldier,
{
	tEnemy = tNPC1,
}))
