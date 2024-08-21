----------------------------------------------------------------------
-- Name: GangHarassmentType State
-- Description: A group of gang members stand around and harass pedestrians
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


----------------------------------------------------------------------
-- Spawn criteria for this crime:
--	Spawned on a probability basis
--	Gang influence affects spawn probability
--	Maximum of 2 instances of this crime can be active at once
----------------------------------------------------------------------
-- Instance parameters:
--	sInstanceName = Unique name for this instance ( required )
--	sSpawnPointName = Spawn point for this instance ( optional, derived from sInstanceName by appending "_Position" if not provided )
--	sTriggerZoneName = Trigger zone. When pedestrian enters this they are involved in the crime ( optional, derived from sInstanceName by appending "_TriggerZone" if not provided )
--	nMaxGangMembers = Maximum number of gang members. Gang is initially set to this size ( optional )
--	nMaxSpawnDist =	Maximum distance from centre of spawn point that a gang member will be spawned ( optional )
--	nMinSpawnDist = Mimimum distance from centre of spawn point that a gang member will be spawned ( optional )
--	tGang = Gang that this crime is afiliated with ( optional )
--	sNPCSpawnPointNameBase = Base NPC spawn point for this instance ( optional, derived from sInstanceName by appending "_NPC_SpawnPoint_" if not provided )
--	nNumNPCSpawnPoints = Number of spawn points to choose from when spawning gang members ( optional )
--	nSpawnProbability = Percentage probability of spawning ( optional )
----------------------------------------------------------------------


require "System\\State"
require "State\\Crime\\GangHarassment\\GangHarassment"

namespace ("GangHarassmentType")

GangHarassmentType = Create (State,
{
	sStateName = "GangHarassmentType",
	nMaxActiveInstances = 2,
})


-- This function should run a script that will provide the atCrimeDetails
function GangHarassmentType:RunConfigScript (sConfigScriptName)

	-- Run the script to set up the crime details
	assert (sConfigScriptName and string.len (sConfigScriptName) > 0)
	RunScript (sConfigScriptName)

	-- Register all instances with the manager
	for nIndex = 1, table.getn (GangHarassment.atCrimeDetails) do
		AmbientCrimeManager.RegisterNewInstance("GangHarassment",
												GangHarassment.atCrimeDetails[nIndex].sInstanceName,
												self:RetSpawnPointName (nIndex))
	end
	
end


function GangHarassmentType:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Default parameters
	self.tDefaultParameters = CreateReadOnly
	{
		nMaxGangMembers =		4,
		nMaxSpawnDist =			5,
		nMinSpawnDist =			3,
		tGang =					tMuchachos,
		nNumNPCSpawnPoints =	6,
		nSpawnProbability =		100,
	}

	-- Internal state data
	self.nNumActiveInstances = 0
end


function GangHarassmentType:OnExit ()
	-- Call parent
	State.OnExit (self)
end


function GangHarassmentType:OnEvent (tEvent)
	-- Call parent
	return State.OnEvent (self, tEvent)
end


function GangHarassmentType:CanSpawnInstance  (sInstanceName)
	-- Don't allow creation if we've already got enough of these crimes active
	if self.nNumActiveInstances >= self.nMaxActiveInstances then
		AmbientCrimeManager.SetCrimeDebugString (sInstanceName, "Failed to spawn - Already enough active instances of this type")
		return false
	end

	-- Probability
	for nIndex = 1, table.getn (GangHarassment.atCrimeDetails) do
		if sInstanceName == GangHarassment.atCrimeDetails[nIndex].sInstanceName then
			-- Get probability index ( 0 to 100 )
			local nProb = self.tDefaultParameters.nSpawnProbability
			if GangHarassment.atCrimeDetails[nIndex].nSpawnProbability then
				nProb = GangHarassment.atCrimeDetails[nIndex].nSpawnProbability
			end

-- removed gang influence for m17 (pkg 2/9/05 )
--			-- Factor in gang influence ( 0 to 1 )
--			local tSpawnPoint = cInfo.FindInfoByName (self:RetSpawnPointName (nIndex))
--			assert (tSpawnPoint)
--			local tGang = self:RetGang (nIndex)
--			local nGangInfluence = tGang:RetInfluence (tSpawnPoint:RetPosition ())
--			nProb = nProb * nGangInfluence

			-- Perform the test
			if cAIPlayer.Rand (0, 100) >= nProb then
				AmbientCrimeManager.SetCrimeDebugString (sInstanceName, "Failed to spawn - Didn't pass probability test")
				return false
			end
			break
		end
	end

	-- All tests passed so let's say that we are happy to spawn this instance
	return true
end


function GangHarassmentType:CreateInstance (sInstanceName)
	local bWasSpawned = false
	
	-- Find the parameters for this particular instance
	for nIndex = 1, table.getn (GangHarassment.atCrimeDetails) do
		if sInstanceName == GangHarassment.atCrimeDetails[nIndex].sInstanceName then

			-- Create a parameter table
			local tParameters = {}

			-- Copy in our unique names
			tParameters.sInstanceName =	GangHarassment.atCrimeDetails[nIndex].sInstanceName
			tParameters.sSpawnPointName = self:RetSpawnPointName (nIndex)
			if GangHarassment.atCrimeDetails[nIndex].sTriggerZoneName then
				tParameters.sTriggerZoneName = GangHarassment.atCrimeDetails[nIndex].sTriggerZoneName
			else
				tParameters.sTriggerZoneName = GangHarassment.atCrimeDetails[nIndex].sInstanceName .. "_TriggerZone"
			end

			-- Load up default or instance specific parameters
			if GangHarassment.atCrimeDetails[nIndex].nMaxGangMembers then
				tParameters.nMaxGangMembers = GangHarassment.atCrimeDetails[nIndex].nMaxGangMembers
			else
				tParameters.nMaxGangMembers = self.tDefaultParameters.nMaxGangMembers
			end
			if GangHarassment.atCrimeDetails[nIndex].nMaxSpawnDist then
				tParameters.nMaxSpawnDist = GangHarassment.atCrimeDetails[nIndex].nMaxSpawnDist
			else
				tParameters.nMaxSpawnDist = self.tDefaultParameters.nMaxSpawnDist
			end
			if GangHarassment.atCrimeDetails[nIndex].nMinSpawnDist then
				tParameters.nMinSpawnDist = GangHarassment.atCrimeDetails[nIndex].nMinSpawnDist
			else
				tParameters.nMinSpawnDist = self.tDefaultParameters.nMinSpawnDist
			end
			tParameters.tGang = self:RetGang (nIndex)

			-- Spawn points
			tParameters.sNPCSpawnPointNameBase = self:RetNPCSpawnPointNameBase (nIndex)
			if GangHarassment.atCrimeDetails[nIndex].nNumNPCSpawnPoints then
				tParameters.nNumNPCSpawnPoints = GangHarassment.atCrimeDetails[nIndex].nNumNPCSpawnPoints
			else
				tParameters.nNumNPCSpawnPoints = self.tDefaultParameters.nNumNPCSpawnPoints
			end

			-- Now spawn the instance and pass in our parameter table
			local MyInstance = AmbientCrimeManager.NewInstance (sInstanceName)
			assert (MyInstance)
			MyInstance:SetState (GangHarassment.GangHarassment)
			MyInstance:RetState():Construct (tParameters)
			
			self.nNumActiveInstances = self.nNumActiveInstances + 1
			assert (self.nNumActiveInstances <= table.getn (GangHarassment.atCrimeDetails))

			bWasSpawned = true
			break
		end
	end
	
	assert (bWasSpawned == true)
end


function GangHarassmentType:DestroyInstance (sInstanceName)
	self.nNumActiveInstances = self.nNumActiveInstances - 1
	assert (self.nNumActiveInstances >= 0)
end


function GangHarassmentType:RetSpawnPointName (nIndex)
	local sSpawnPointName
	
	if GangHarassment.atCrimeDetails[nIndex].sSpawnPointName then
		-- Spawn point was explicity named
		sSpawnPointName = GangHarassment.atCrimeDetails[nIndex].sSpawnPointName
	else
		-- Spawn point was not explicitly named so derive it
		sSpawnPointName = GangHarassment.atCrimeDetails[nIndex].sInstanceName .. "_Position"
	end
	
	return sSpawnPointName
end


function GangHarassmentType:RetNPCSpawnPointNameBase (nIndex)
	local sSpawnPointName
	
	if GangHarassment.atCrimeDetails[nIndex].sNPCSpawnPointNameBase then
		-- Spawn point base name was explicity named
		sNPCSpawnPointNameBase = GangHarassment.atCrimeDetails[nIndex].sNPCSpawnPointNameBase
	else
		-- Spawn point base name was not explicitly named so derive it
		sNPCSpawnPointNameBase = GangHarassment.atCrimeDetails[nIndex].sInstanceName .. "_NPC_SpawnPoint_"
	end
	
	return sNPCSpawnPointNameBase
end


function GangHarassmentType:RetGang (nIndex)
	local tGang
	
	if GangHarassment.atCrimeDetails[nIndex].tGang then
		-- Gang was explicity named
		tGang = GangHarassment.atCrimeDetails[nIndex].tGang
	else
		-- Gang was not explicitly named so return default
		tGang = self.tDefaultParameters.tGang
	end
	
	return tGang
end
