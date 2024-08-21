----------------------------------------------------------------------
-- Name: MoveTest Script
--	Description:
-- 1. Spawns an NPC
-- 2. The NPC continually moves towards the player (unless he loses sight of him)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Action\\Chase\\Chase"

local tAiManager = cAiManager.RetAiManager ()
local tPlayer = tAiManager:RetPlayer (0)

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)

tNPC:SetState (Create (Chase,
{
	nMovementType = eMovementType.nWalk,
	tTarget = tPlayer,
}))
