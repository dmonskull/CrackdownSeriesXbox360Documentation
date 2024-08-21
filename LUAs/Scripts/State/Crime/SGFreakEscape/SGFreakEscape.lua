----------------------------------------------------------------------
-- Name: SGFreakEscape State
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
require "State\\Crime\\SGFreakEscape\\Crime"
require "State\\NPC\\Character\\StreetSoldier"


namespace ("SGFreakEscape")

SGFreakEscape = Create (AmbientCrimeState,
{
	sStateName = "SGFreakEscape",
})


function SGFreakEscape:Construct (tParameters)
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

	-- Go into the crime state
	self:PushState (Create (Crime, {}))

	-- Initialise arrays
	self.atGangMember1 = {}
	self.atGangMember2 = {}
	self.asSpawnPoints1 = {}
	self.asSpawnPoints2 = {}
	self.abIsInActivityVolume1 = {}
	self.abIsInActivityVolume2 = {}

	-- Generate array of spawn positions
	self:GenerateSpawnPoints ()

	-- Spawn gang members - Gang 1
	for i=1, self.tParameters.nGangMembers1 do

		-- Get the spawn location
		local sSpawnLocation = self.asSpawnPoints1[i]

		-- Get the prototype name
		local sProtoName = "AIStreetSoldier5"

		-- Spawn the character
		local tGangMember = cAIPlayer.SpawnNPCAtNamedLocation (sProtoName, sSpawnLocation)
		assert (tGangMember)
		tGangMember:SetTeamSide (self.tParameters.tGang1)
        
        -- add weapon  
 --       tGangMember:AddEquipment ("M16")
        tGangMember:AddEquipment ("SMG")

		-- Add him to the group
		self:OnAddGangMember1 (tGangMember)

	end

	-- Spawn gang members - Gang 2
	for i=1, self.tParameters.nGangMembers2 do

		-- Get the spawn location
		local sSpawnLocation = self.asSpawnPoints2[i]

		-- Get the prototype name
		local sProtoName = "AICivilian4"

		-- Spawn the character
		local tGangMember = cAIPlayer.SpawnNPCAtNamedLocation (sProtoName, sSpawnLocation)
		assert (tGangMember)
		tGangMember:SetTeamSide (self.tParameters.tGang2)

		-- Add him to the group
		self:OnAddGangMember2 (tGangMember)

	end

	-- Subscribe to a 2 second looping timer event
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nTimerID = self:AddTimer (2, true)

end


function SGFreakEscape:OnExit ()

	if self.bDeleteMissionObjects then

		-- Delete all the gang members
		while self:RetNumGangMembers1 () >= 1 do
			local tGangMember = self.atGangMember1[1]
			self:OnLostGangMember1 (tGangMember)
			AILib.DeleteGameObject (tGangMember)
		end
		while self:RetNumGangMembers2 () >= 1 do
			local tGangMember = self.atGangMember2[1]
			self:OnLostGangMember2 (tGangMember)
			AILib.DeleteGameObject (tGangMember)
		end
		
	else
	
		-- Turn them all into ordinary street soldiers
		while self:RetNumGangMembers1 () >= 1 do
			local tGangMember = self.atGangMember1[1]
			self:OnLostGangMember1 (tGangMember)
			tGangMember:SetState (StreetSoldier)
			tGangMember:SetGameImportance (eGameImportance.nDefault)
		end
		while self:RetNumGangMembers2 () >= 1 do
			local tGangMember = self.atGangMember2[1]
			self:OnLostGangMember2 (tGangMember)
			tGangMember:SetState (StreetSoldier)
			tGangMember:SetGameImportance (eGameImportance.nDefault)
		end

	end

	-- Delete looping timer
	self:DeleteTimer (self.nTimerID)

	-- Destroy the team objects
	cTeamManager.DestroyTeam (self.tTeam1)
	cTeamManager.DestroyTeam (self.tTeam2)

	-- Call parent
	AmbientCrimeState.OnExit (self)
end


function SGFreakEscape:OnEvent (tEvent)

	local tState = self:RetActiveState ()

	-- Timer event
	-- We use this timer event to periodically go through all of the npcs and check
	-- if they are far enough away from the player that the crime can be safely ended
	-- NB: This is a temporary hack until the activity volume system is replaced
	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		if self:IsCrimeWithinActivityVolume() == false then
			-- No npcs still within range of the player so kill the crime
			self.tHost:SetHasEnded ()
		end
			
	end

	-- Call parent
	return AmbientCrimeState.OnEvent (self, tEvent)
end


-- Check to see whether any of the crimes entities are still within an activity zone
function SGFreakEscape:IsCrimeWithinActivityVolume ()

	for i=1, self:RetNumGangMembers1 () do
		if self.atGangMember1[i]:IsInsideAnyActivityVolume () then
			return true
		end
	end

	for i=1, self:RetNumGangMembers2 () do
		if self.atGangMember2[i]:IsInsideAnyActivityVolume () then
			return true
		end
	end

	local tSpawnPoint = cInfo.FindInfoByName (self.tParameters.sSpawnPointName)
	assert (tSpawnPoint)
	if tSpawnPoint:IsInsideAnyActivityVolume () then
		return true
	end
	
	return false
end


function SGFreakEscape:OnAddGangMember1 (tGangMember)

	-- Insert the gang member at the next available slot in the array
	local i = self:RetNumGangMembers1 () + 1
	self.atGangMember1[i] = tGangMember

	-- Subscribe to events
	self:SubscribeNPCTriggerEvents (tGangMember)
	
	self.abIsInActivityVolume1[i] = true

	-- Add to teams
	self.tTeam1:AddEntity (tGangMember)
	self.tTeam2:AddEnemy (tGangMember, eEnemyStatus.nActive)

	-- Make him critical so that we can manage him ourselves
	tGangMember:SetGameImportance (eGameImportance.nCritical)

end


function SGFreakEscape:OnAddGangMember2 (tGangMember)

	-- Insert the gang member at the next available slot in the array
	local i = self:RetNumGangMembers2 () + 1
	self.atGangMember2[i] = tGangMember

	-- Subscribe to events
	self:SubscribeNPCTriggerEvents (tGangMember)
	
	self.abIsInActivityVolume2[i] = true

	-- Add to teams
	self.tTeam2:AddEntity (tGangMember)
	self.tTeam1:AddEnemy (tGangMember, eEnemyStatus.nActive)

	-- Make him critical so that we can manage him ourselves
	tGangMember:SetGameImportance (eGameImportance.nCritical)

end


-- NPC died
function SGFreakEscape:OnNPCDied (tNPC, tKiller)
	self:OnLostGangMember (tNPC)
end


-- Delete a Gang member when you don't know which team he belongs to
function SGFreakEscape:OnLostGangMember (tGangMember)

	-- Find out which gang we need to remove this member from
	if tGangMember:RetTeam () == self.tTeam1 then
		self:OnLostGangMember1 (tGangMember)
	elseif tGangMember:RetTeam () == self.tTeam2 then
		self:OnLostGangMember2 (tGangMember)
	end
	
end


-- Delete a Gang member out of the array for team 1
function SGFreakEscape:OnLostGangMember1 (tGangMember)

	-- Find the gang members index in the array
	for i=0, self:RetNumGangMembers1 () do
		if tGangMember == self.atGangMember1[i] then
			nIndex = i
			break
		end
	end
	assert (nIndex)

	-- Unsubscribe events
	self:UnsubscribeNPCTriggerEvents (tGangMember)

	-- Shift all the elements in the array down one place
	for j=nIndex, self:RetNumGangMembers1 () do

		self.asSpawnPoints1[j] = self.asSpawnPoints1[j + 1]
		self.atGangMember1[j] = self.atGangMember1[j + 1]
		self.abIsInActivityVolume1[j] = self.abIsInActivityVolume1[j + 1]

	end

	if self:RetNumGangMembers1 () == 0 and self:RetNumGangMembers2 () == 0 then
		-- Gangs are now empty so the crime can end
		self.tHost:SetHasEnded ()
	end
end


-- Delete a Gang member out of the array for team 2
function SGFreakEscape:OnLostGangMember2 (tGangMember)

	-- Find the gang members index in the array
	for i=0, self:RetNumGangMembers2 () do
		if tGangMember == self.atGangMember2[i] then
			nIndex = i
			break
		end
	end
	assert (nIndex)

	-- Unsubscribe events
	self:UnsubscribeNPCTriggerEvents (tGangMember)

	-- Shift all the elements in the array down one place
	for j=nIndex, self:RetNumGangMembers2 () do

		self.asSpawnPoints2[j] = self.asSpawnPoints2[j + 1]
		self.atGangMember2[j] = self.atGangMember2[j + 1]
		self.abIsInActivityVolume2[j] = self.abIsInActivityVolume2[j + 1]

	end

	if self:RetNumGangMembers1 () == 0 and self:RetNumGangMembers2 () == 0 then
		-- Gangs are now empty so the crime can end
		self.tHost:SetHasEnded ()
	end
end


-- Create two arrays of spawn points for the gang members to stand at
-- Spawn point names are generated from the sNPCSpawnPointNameBase with a team number 
-- and a spawnpoint number appended to it. For example: 001_SGFreakEscape_NPC_SpawnPoint_1_01 
-- would be the first available spawn point for gang 1
function SGFreakEscape:GenerateSpawnPoints ()

	-- Ensure that we have enough spawn points
	assert (self.tParameters.nGangMembers1 <= self.tParameters.nNumNPCSpawnPoints1)
	assert (self.tParameters.nGangMembers2 <= self.tParameters.nNumNPCSpawnPoints2)

	-- Make a table of spawn point indices for gang 1
	local anSpawnPoints1 = {}
	for nIndex = 1, self.tParameters.nNumNPCSpawnPoints1 do
		anSpawnPoints1[nIndex] = nIndex
	end
	
	-- Shuffle it a few times
	for nIndex = 1, self.tParameters.nNumNPCSpawnPoints1 do
		local nShuffeIndex = cAIPlayer.Rand (1, self.tParameters.nNumNPCSpawnPoints1)
		local nSwap = anSpawnPoints1[nIndex]
		anSpawnPoints1[nIndex] = anSpawnPoints1[nShuffeIndex]
		anSpawnPoints1[nShuffeIndex] = nSwap
	end

	-- Now assign each of the spawn points to an entry from this shuffled table
	for nIndex = 1, self.tParameters.nGangMembers1 do
		self.asSpawnPoints1[nIndex] = string.format ("%s1_%02d", self.tParameters.sNPCSpawnPointNameBase, anSpawnPoints1[nIndex])
	end

	-- Make a table of spawn point indices for gang 2
	local anSpawnPoints2 = {}
	for nIndex = 1, self.tParameters.nNumNPCSpawnPoints2 do
		anSpawnPoints2[nIndex] = nIndex
	end
	
	-- Shuffle it a few times
	for nIndex = 1, self.tParameters.nNumNPCSpawnPoints2 do
		local nShuffeIndex = cAIPlayer.Rand (1, self.tParameters.nNumNPCSpawnPoints2)
		local nSwap = anSpawnPoints2[nIndex]
		anSpawnPoints2[nIndex] = anSpawnPoints2[nShuffeIndex]
		anSpawnPoints2[nShuffeIndex] = nSwap
	end

	-- Now assign each of the spawn points to an entry from this shuffled table
	for nIndex = 1, self.tParameters.nGangMembers2 do
		self.asSpawnPoints2[nIndex] = string.format ("%s2_%02d", self.tParameters.sNPCSpawnPointNameBase, anSpawnPoints2[nIndex])
	end

end


-- Returns the number of gang members in gang 1
function SGFreakEscape:RetNumGangMembers1 ()
	return table.getn (self.atGangMember1)
end


-- Returns the number of gang members in gang 2
function SGFreakEscape:RetNumGangMembers2 ()
	return table.getn (self.atGangMember2)
end

