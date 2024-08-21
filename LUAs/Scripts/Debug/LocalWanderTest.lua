----------------------------------------------------------------------
-- Name: LocalWanderTest Script
-- Description: Example script for a character who wanders in a local area
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Character\\Pedestrian"
require "State\\NPC\\Behaviour\\Wander\\LocalWanderEx"

LocalPedestrian = Create (Pedestrian,
{
	sStateName = "LocalPedestrian",
})

function LocalPedestrian:OnEnter ()
	-- Call parent
	Pedestrian.OnEnter (self)

	self.atNodeScripts = {}
	self.atNodeScripts[1] = 
	{
		sScriptName = "Config\\PatrolNodes\\Crouch",
	}
	self.atNodeScripts[2] = 
	{
		sScriptName = "Config\\PatrolNodes\\Yawn",
		nDuration = 5,
	}
	self.atNodeScripts[3] = 
	{
		sScriptName = "Config\\PatrolNodes\\StandIdle",
		nDuration = 5,
	}
end

function LocalPedestrian:CreateIdleState ()
	return Create (LocalWanderEx,
	{
		nMinNodeScriptTime = 5,
		nMaxNodeScriptTime = 10,
		atNodeScripts = self.atNodeScripts,
		bUseRadius = true,
		vCentrePosition = self.tHost:RetCentre (),
		nRadius = 10,
	})
end

function LocalPedestrian:InIdleState ()
	return self:IsInState (LocalWanderEx)
end

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
tNPC:SetTeamSide (tCivilians)
tNPC:SetPersonality (ePersonality.nNormal)
tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)
tNPC:SetState (LocalPedestrian)
