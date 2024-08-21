----------------------------------------------------------------------
-- Name: LMAssault State
--	Description: A group of gang members stand around and harass pedestrians
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


----------------------------------------------------------------------
-- Required parameters:
--	sInstanceName = Unique name for this instance
--	sSpawnPointName = Spawn point for this instance
--	sTriggerZoneName = Trigger zone. When pedestrian enters this they are involved in the crime ( optional, derived from sInstanceName by appending "_TriggerZone" if not provided )
--	nMaxGangMembers = Maximum number of gang members. Gang is initially set to this size
--	nMaxSpawnDist =	Maximum distance from centre of spawn point that a gang member will be spawned
--	nMinSpawnDist = Mimimum distance from centre of spawn point that a gang member will be spawned
--	tGang = Gang that this crime is afiliated with
--	sNPCSpawnPointNameBase = Base NPC spawn point for this instance
--	nNumNPCSpawnPoints = Number of spawn points to choose from when spawning gang members
----------------------------------------------------------------------


require "State\\Crime\\AmbientCrimeState"
require "State\\Crime\\LMAssault\\PreCrime"
require "State\\Crime\\LMAssault\\Crime"
require "State\\Crime\\LMAssault\\Reset"
require "State\\Crime\\LMAssault\\HarassEnemy"
require "State\\Crime\\LMAssault\\AttackEnemy"
require "State\\NPC\\Character\\Pedestrian"
require "State\\NPC\\Character\\StreetSoldier"

namespace ("LMAssault")

LMAssault = Create (AmbientCrimeState,
{
	sStateName = "LMAssault",
})

function LMAssault:OnEnter ()
	-- Call parent
	AmbientCrimeState.OnEnter (self)
	Emit ("test string 2 " .. self.tHost:RetName ())
end

function LMAssault:Construct (tParameters)
	-- Check that all required parameters are present and correct
	assert (type (tParameters.sInstanceName) == "string")
	assert (type (tParameters.sSpawnPointName) == "string")
	assert (type (tParameters.sTriggerZoneName) == "string")
	assert (type (tParameters.nMaxGangMembers) == "number")
	assert (type (tParameters.nMaxSpawnDist) == "number")
	assert (type (tParameters.nMinSpawnDist) == "number")
	assert (tParameters.tGang)
	assert (type (tParameters.sNPCSpawnPointNameBase) == "string")
	assert (type (tParameters.nNumNPCSpawnPoints) == "number")

	self.tParameters = tParameters

	-- Initialise arrays
	self.atGangMember = {}
	self.avSpawnPoints = {}
	self.avFacePoints = {}
	self.abIsInActivityVolume = {}

	-- Generate array of spawn positions
	self:GenerateSpawnPoints (self.tParameters.nMaxGangMembers)

	-- Spawn gang members
	for i=1, self.tParameters.nMaxGangMembers do

		-- Get the spawn position
		local vPos = self.avSpawnPoints[i]

		-- Get the prototype name
		local sProtoName = "AIStreetSoldier5"-- .. tostring (cAIPlayer.Rand (1, 2))

		-- Spawn the character
		local tGangMember = cAIPlayer.SpawnNPC (sProtoName, vPos)
		tGangMember:SetTeamSide (self.tParameters.tGang)
		tGangMember:SetPersonality (ePersonality.nNormal)
		tGangMember:SetShootingAccuracy (eShootingAccuracy.nNormal)
-- remove guns		tGangMember:AddEquipment ("M16")

		-- Add him to the group
		self:OnAddGangMember (tGangMember)

		-- Make him critical so that we can manager him ourselves
		tGangMember:SetGameImportance (eGameImportance.nCritical)

	end
	
	-- Go into the pre-crime state
	self:PushState (Create (PreCrime, {}))
    
	-- Initialise trigger zone
	local tTriggerZone = self:InitTriggerZone (self.tParameters.sTriggerZoneName)

	-- Subscribe events
	self.nZoneAIPlayerID = self:Subscribe (eEventType.AIE_ZONE_AIPLAYER, self:RetTriggerZone ())

	-- Subscribe to a 2 second looping timer event
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nTimerID = self:AddTimer (2, true)

end

function LMAssault:OnExit ()

	self.tHost:NotifyCustomEvent ("HarassF")

	if self.bDeleteMissionObjects then

		-- Delete all the gang members
		while self:RetNumGangMembers () >= 1 do
			local tGangMember = self.atGangMember[1]
			self:OnLostGangMember (tGangMember)
			AILib.DeleteGameObject (tGangMember)
		end

	else

		-- Turn them all into ordinary street soldiers
		while self:RetNumGangMembers () >= 1 do
			local tGangMember = self.atGangMember[1]
			self:OnLostGangMember (tGangMember)
			tGangMember:SetState (StreetSoldier)
			tGangMember:SetGameImportance (eGameImportance.nDefault)
		end

	end

	-- Call parent
	AmbientCrimeState.OnExit (self)
end

function LMAssault:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	-- Hack - njr
	if not tState then
		
		return true

	-- Crime finished
	elseif tState:IsA (Crime) then

		self:ChangeState (Create (Reset, {}))
		return true

	-- They are back in their spawn positions
	elseif tState:IsA (Reset) then

		self:ChangeState (Create (PreCrime, {}))
		return true

	-- Finished harassing the player
	elseif tState:IsA (HarassEnemy) then

		-- Player is still around, escalate to attacking the player
		if tState:Escalate () then

			self:ChangeState (Create (AttackEnemy, 
			{
				tEnemy = tState.tEnemy,
			}))

		-- Player has gone, stand down and reset to original positions
		else

			self:ChangeState (Create (PreCrime, {}))

		end
		return true

	-- Attack Enemy finished
	elseif tState:IsA (AttackEnemy) then

		-- If more than half of the gang members have been killed, 
		-- disband the group and end the mission
		if self:RetNumGangMembers () <  self.tParameters.nMaxGangMembers / 2 then

			self:SetDeleteMissionObjects (false)
			self:Finish ()

		else
			self:ChangeState (Create (Reset, {}))
		end
		return true

	end

	-- Call parent
	return AmbientCrimeState.OnActiveStateFinished (self)
end

function LMAssault:OnEvent (tEvent)

	local tState = self:RetActiveState ()

	-- An AI player wandered into the trigger zone
	if tEvent:HasID (self.nZoneAIPlayerID) then

		if tEvent:IsEntering () then

			-- Pedestrian entered the trigger zone
			local tInstigator = tEvent:RetInstigator ()
			if tInstigator:RetState () and tInstigator:RetState ():IsA (Pedestrian) and tInstigator:RetState ():IsAvailable () then
			
				self:OnDetectedPedestrian (tInstigator)

			-- Streetsoldier entered the trigger zone
			elseif tInstigator:RetState () and tInstigator:RetState ():IsA (StreetSoldier) and tInstigator:RetState ():IsAvailable () then

				self:OnDetectedStreetSoldier (tInstigator)

			end

		end
		return true

	-- Timer event
	-- We use this timer event to periodically go through all of the npcs and check
	-- if they are far enough away from the player that the crime can be safely ended
	-- NB: This is a temporary hack until the activity volume system is replaced
	elseif tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		if self:IsCrimeWithinActivityVolume() == false then
			-- No npcs still within range of the player so kill the crime
			self.tHost:SetCrimeDebugString ("All NPCs out of range")
			self.tHost:SetHasEnded ()
		end
			
	end

	-- Call parent
	return AmbientCrimeState.OnEvent (self, tEvent)
end

-- Check to see whether any of the crimes entities are still within an activity zone
function LMAssault:IsCrimeWithinActivityVolume ()

	for i=1, self:RetNumGangMembers () do
		if self.atGangMember[i]:IsInsideAnyActivityVolume () then
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

-- Pedestrian entered the trigger zone
function LMAssault:OnDetectedPedestrian (tPedestrian)

	if self:IsInState (PreCrime) then

		-- Go into the Crime state
		self:ChangeState (Create (Crime, 
		{
			tVictim = tPedestrian,
			atGangMember = self.atGangMember,
		}))
	
		-- Make him critical so that we can manager him ourselves
		tPedestrian:SetGameImportance (eGameImportance.nCritical)

	end

end

-- Streetsoldier entered the trigger zone
function LMAssault:OnDetectedStreetSoldier (tStreetSoldier)

	if self:IsInState (PreCrime) then

		if self:RetNumGangMembers () < self.tParameters.nMaxGangMembers then
	
			-- Temporary - Make the street soldier have critical importance so he won't be deleted
			tStreetSoldier:SetGameImportance (eGameImportance.nCritical)

			-- Add the streetsoldier to the gang
			self:OnAddGangMember (tStreetSoldier)
			self:ChangeState (Create (Reset, {}))

		end

	end

end

-- Heard a sound made by an enemy whose location is not known
function LMAssault:OnNPCHeardSuspiciousSound (tNPC, vPosition)
end

-- Took damage from an enemy - the attacker's location is not necessarily known
function LMAssault:OnNPCAttacked (tNPC, tAttacker)

	if not self:IsInState (AttackEnemy) then

		self:ChangeState (Create (AttackEnemy, {}))

	end

end

-- Seen enemy, or was told about the location of the enemy by a team mate
function LMAssault:OnNPCDetectedEnemy (tNPC, tEnemy)

	if self:IsInState (PreCrime) then

		self:ChangeState (Create (HarassEnemy, 
		{
			tEnemy = tEnemy,
		}))

	end

end

-- NPC died
function LMAssault:OnNPCDied (tNPC, tKiller)
	self:OnLostGangMember (tNPC)
end

function LMAssault:OnAddGangMember (tGangMember)

	-- Insert the gang member at the next available slot in the array
	local i = self:RetNumGangMembers () + 1
	self.atGangMember[i] = tGangMember
	self.abIsInActivityVolume[i] = true

	-- Subscribe to events
	self:SubscribeNPCTriggerEvents (tGangMember)

end

-- Delete a Gang member out of the array
function LMAssault:OnLostGangMember (tGangMember)
	-- Unsubscribe events
	self:UnsubscribeNPCTriggerEvents (tGangMember)

	local i = 1
	while self.atGangMember[i] and self.atGangMember[i] ~= tGangMember do
		i = i + 1
	end
	while self.atGangMember[i] do
		self.avSpawnPoints[i] = self.avSpawnPoints[i + 1]
		self.avFacePoints[i] = self.avFacePoints[i + 1]
		self.atGangMember[i] = self.atGangMember[i + 1]
		self.abIsInActivityVolume[i] = self.abIsInActivityVolume[i + 1]
		i = i + 1
	end

	-- If there are no gang members left then end the crime
	if self:RetNumGangMembers () == 0 then
		self.tHost:SetCrimeDebugString ("Lost last gang member")
		self.tHost:SetHasEnded ()
	end

end

function LMAssault:RetNumGangMembers ()
	return table.getn (self.atGangMember)
end

-- Create an array of spawn points for the gang members to stand at
-- Spawn point names are generated from the sNPCSpawnPointNameBase with a spawnpoint
-- number appended to it. For example: 001_LMAssault_NPC_SpawnPoint_01 
-- would be the first available spawn point
function LMAssault:GenerateSpawnPoints (nNumGangMembers)

	-- Ensure that we have enough spawn points
	assert (nNumGangMembers <= self.tParameters.nNumNPCSpawnPoints)

	-- Make a table of spawn point indices
	local anSpawnPoints = {}
	for nIndex = 1, self.tParameters.nNumNPCSpawnPoints do
		anSpawnPoints[nIndex] = nIndex
	end
	
	-- Shuffle it a few times
	for nIndex = 1, self.tParameters.nNumNPCSpawnPoints do
		local nShuffeIndex = cAIPlayer.Rand (1, self.tParameters.nNumNPCSpawnPoints)
		local nSwap = anSpawnPoints[nIndex]
		anSpawnPoints[nIndex] = anSpawnPoints[nShuffeIndex]
		anSpawnPoints[nShuffeIndex] = nSwap
	end

	-- Now assign each of the spawn points to an entry from this shuffled table
	for nIndex = 1, nNumGangMembers do
		local sSpawnPointName = string.format ("%s%02d", self.tParameters.sNPCSpawnPointNameBase, anSpawnPoints[nIndex])
		local tSpawnPoint = cInfo.FindInfoByName (sSpawnPointName)
		assert (tSpawnPoint)
        Emit ("GangMember: " .. tostring (nIndex) .. ": " .. sSpawnPointName)
		self.avSpawnPoints[nIndex] = tSpawnPoint:RetPosition ()
	end

	-- Make them face random positions near the spawn point
	local vCenter = self.tHost:RetPosition ()
	for i=1, nNumGangMembers do
	
		local nRandX = cAIPlayer.Rand (-2,2)
		local nRandZ = cAIPlayer.Rand (-2,2)
		
		local vAdd = MakeVec3 (nRandX, 0, nRandZ)
		
		self.avFacePoints[i] = VecAdd (vCenter, vAdd)

	end

end

-- Return a pointer to the trigger zone
function LMAssault:RetTriggerZone ()
	local tZoneManager = cZoneManager.RetZoneManager ()
	assert (tZoneManager)

	local tTriggerZone = tZoneManager:RetNamedAITriggerZone (self.tParameters.sTriggerZoneName)
	assert (tTriggerZone)

	return tTriggerZone
end
