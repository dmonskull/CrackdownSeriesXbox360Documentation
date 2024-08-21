require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Character\\Guard"
require "Debug\\SpawnInFrontOfPlayer"

local tNPC = SpawnNPCInFrontOfPlayer("AIStreetSoldier1")
tNPC:SetState(Create(Guard, 
{
	tPatrolRouteNames = {"billlevel\\Hill_BalconyA_patrol"}
}
))

--local tNPC = cAIPlayer.SpawnNPCAtNamedLocation ( "AIStreetSoldier1", "PedestrianStart" )
--local tNPC = cAIPlayer.SpawnNPC("AIStreetSoldier1", 1098, 31, -1031)

--tNPC:SetState (Create (Move, 
--{
	--vDestination = MakeVec3 (1047, 30.9, -1017), -- Down the pavement, same cell
	--vDestination = MakeVec3 (1053, 30.8, -986), -- Around the corner, different cell
	--vDestination = MakeVec3 (1135, 30, -889), -- Up the steps from the road
	--vDestination = MakeVec3 (1129.4, 27.7, -891), -- Half way up the steps from the road
--})) 

--cAiManager.RetAiManager():SummonAIVehicleAtPos(1047,30.9,-1017)

