----------------------------------------------------------------------
-- Name: GangWar State
-- Description: A group of gang members stand around and have a fight
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


----------------------------------------------------------------------
-- Required parameters:
--	sInstanceName = Unique name for this instance
--	sSpawnPointName = Spawn point for this instance
--	tGang1 = 1st gang that this crime is afiliated with
--	tGang2 = 2nd gang that this crime is afiliated with
--	nGangMembers1 = Maximum number of gang members from gang 1
--	nGangMembers2 = maximum number of gang members from gang 2
--	sNPCSpawnPointNameBase = Base NPC spawn point for this instance
--	nNumNPCSpawnPoints1 = Number of spawn points for gang 1 to choose from when spawning gang members
--	nNumNPCSpawnPoints2 = Number of spawn points for gang 2 choose from when spawning gang members
----------------------------------------------------------------------

require "State\\Crime\\AmbientCrimeState"
require "State\\Crime\\GangWar\\GangWarTeam"

namespace ("GangWar")

GangWar = Create (AmbientCrimeState,
{
	sStateName = "GangWar",
})

function GangWar:Construct (tParameters)
	-- Check that all required parameters are present and correct
	assert (type (tParameters.sInstanceName) == "string")
	assert (type (tParameters.sSpawnPointName) == "string")
	assert (tParameters.tGang1)
	assert (tParameters.tGang2)
	assert (type (tParameters.nGangMembers1) == "number")
	assert (type (tParameters.nGangMembers2) == "number")
	assert (type (tParameters.sNPCSpawnPointNameBase) == "string")
	assert (type (tParameters.nNumNPCSpawnPoints1) == "number")
	assert (type (tParameters.nNumNPCSpawnPoints2) == "number")

	self.tParameters = tParameters

	-- Create teams for the two sides. Team name is based on the instance name
	self.tTeam1 = cTeamManager.CreateTeam (self.tParameters.sInstanceName .. "_Team1", self.tParameters.tGang1, false)
	self.tTeam2 = cTeamManager.CreateTeam (self.tParameters.sInstanceName .. "_Team2", self.tParameters.tGang2, false)

	-- Generate arrays of spawn positions
	local asSpawnPoints1 = self:GenerateSpawnPoints (tParameters.nNumNPCSpawnPoints1, tParameters.nGangMembers1)
	local asSpawnPoints2 = self:GenerateSpawnPoints (tParameters.nNumNPCSpawnPoints2, tParameters.nGangMembers2)

	-- Spawn gang members - Gang 1
	for i=1, self.tParameters.nGangMembers1 do

		-- Get the spawn location
		local sSpawnLocation = asSpawnPoints1[i]

		-- Get the prototype name
		local sProtoName = "AIStreetSoldier5"

		-- Spawn the character
		local tGangMember = cAIPlayer.SpawnNPCAtNamedLocation (sProtoName, sSpawnLocation)
		assert (tGangMember)

		-- Add to teams
		self.tTeam1:AddEntity (tGangMember)
		self.tTeam2:AddEnemy (tGangMember, eEnemyStatus.nActive)

	end

	-- Spawn gang members - Gang 2
	for i=1, self.tParameters.nGangMembers2 do

		-- Get the spawn location
		local sSpawnLocation = asSpawnPoints2[i]

		-- Get the prototype name
		local sProtoName = "AICivilian4"

		-- Spawn the character
		local tGangMember = cAIPlayer.SpawnNPCAtNamedLocation (sProtoName, sSpawnLocation)
		assert (tGangMember)

		-- Add to teams
		self.tTeam2:AddEntity (tGangMember)
		self.tTeam1:AddEnemy (tGangMember, eEnemyStatus.nActive)

	end

	-- Set team states
	self.tTeam1:SetState (GangWarTeam)
	self.tTeam2:SetState (GangWarTeam)

	-- Set up a 2 second looping timer event
	self.nTimerID = self:AddTimer (2, true)
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	-- Subscribe to team idle events which are generated when the teams stop fighting
	-- because they lost track of the enemy or all team members are dead
	self.nTeam1IsIdleID = self:Subscribe (eEventType.AIE_IS_IDLE, self.tTeam1)
	self.nTeam2IsIdleID = self:Subscribe (eEventType.AIE_IS_IDLE, self.tTeam2)

end


function GangWar:OnExit ()
	-- Specifiy whether the teams should delete or disperse their members
	self.tTeam1.tCurrentState.bDeleteMembers = self.bDeleteMissionObjects
	self.tTeam2.tCurrentState.bDeleteMembers = self.bDeleteMissionObjects

	-- Destroy the team objects
	cTeamManager.DestroyTeam (self.tTeam1)
	cTeamManager.DestroyTeam (self.tTeam2)

	-- Call parent
	AmbientCrimeState.OnExit (self)
end

function GangWar:IsCrimeWithinActivityVolume (vPos, nRange)

	if self.tTeam1.tCurrentState:IsAnyoneWithinActivityVolume () then
		return true
	end

	if self.tTeam2.tCurrentState:IsAnyoneWithinActivityVolume () then
		return true
	end
	
	local tSpawnPoint = cInfo.FindInfoByName (self.tParameters.sSpawnPointName)
	assert (tSpawnPoint)
	if tSpawnPoint:IsInsideAnyActivityVolume () then
		return true
	end
	
	return false

end

function GangWar:OnEvent (tEvent)

	-- Timer event
	-- We use this timer event to periodically go through all of the npcs and check
	-- if they are far enough away from the player that the crime can be safely ended
	-- NB: This is a temporary hack until the activity volume system is replaced
	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		if not self:IsCrimeWithinActivityVolume () then
			-- No npcs still within range of the player so kill the crime and delete everyone
			self:SetDeleteMissionObjects (true)
			self.tHost:SetHasEnded ()
		end
		return true

	elseif tEvent:HasID (self.nTeam1IsIdleID) or
		tEvent:HasID (self.nTeam2IsIdleID) then

		if not self.tTeam1:IsDeleted () and not self.tTeam2:IsDeleted () and 
			self.tTeam1:IsIdle () and self.tTeam2:IsIdle () then
			-- Both teams are idle so kill the crime and disperse the gangsters
			self:SetDeleteMissionObjects (false)
			self.tHost:SetHasEnded ()
		end
		return true

	end

	-- Call parent
	return AmbientCrimeState.OnEvent (self, tEvent)
end

-- Create an array of spawn points for the gang members to stand at
-- Spawn point names are generated from the sNPCSpawnPointNameBase with a team number 
-- and a spawnpoint number appended to it. For example: 001_GangWar_NPC_SpawnPoint_1_01 
-- would be the first available spawn point for gang 1
function GangWar:GenerateSpawnPoints (nNumSpawnPoints, nNumGangMembers)

	-- Ensure that we have enough spawn points
	assert (nNumGangMembers <= nNumSpawnPoints)

	-- Make a table of spawn point indices
	local anSpawnPointIndices = {}
	for nIndex = 1, nNumSpawnPoints do
		anSpawnPointIndices[nIndex] = nIndex
	end
	
	-- Shuffle it a few times
	for nIndex = 1, nNumSpawnPoints do
		local nShuffeIndex = cAIPlayer.Rand (1, nNumSpawnPoints)
		local nSwap = anSpawnPointIndices[nIndex]
		anSpawnPointIndices[nIndex] = anSpawnPointIndices[nShuffeIndex]
		anSpawnPointIndices[nShuffeIndex] = nSwap
	end

	-- Now assign each of the spawn points to an entry from this shuffled table
	local asSpawnPointNames = {}
	for nIndex = 1, nNumGangMembers do
		asSpawnPointNames[nIndex] = string.format ("%s1_%02d", self.tParameters.sNPCSpawnPointNameBase, anSpawnPointIndices[nIndex])
	end
	return asSpawnPointNames

end
