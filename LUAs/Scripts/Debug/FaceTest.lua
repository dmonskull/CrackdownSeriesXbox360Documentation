----------------------------------------------------------------------
-- Name: FaceTest Script
--	Description:
-- 1. Spawns an NPC
-- 2. The NPC continually turns to face the player (unless he loses sight of him)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Action\\Turn\\Face"

local tAiManager = cAiManager.RetAiManager ()
local tPlayer = tAiManager:RetPlayer (0)

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)

tNPC:SetState (Create (Face,
{
	tTarget = tPlayer,
}))
