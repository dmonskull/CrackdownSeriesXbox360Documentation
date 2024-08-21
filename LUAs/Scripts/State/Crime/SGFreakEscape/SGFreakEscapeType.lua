----------------------------------------------------------------------
-- Name: SGFreakEscapeType State
-- Description: A group of gang members stand around and have a fight
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


----------------------------------------------------------------------
-- Spawn criteria for this crime:
--	Spawned on a probability basis
--	Maximum of 1 instance of this crime can be active at once
----------------------------------------------------------------------
-- Instance parameters:
--	sInstanceName = Unique name for this instance ( required )
--	sSpawnPointName = Spawn point for this instance ( optional, derived from sInstanceName by appending "_Position" if not provided )
--	tGang1 = 1st gang that this crime is afiliated with ( optional )
--	tGang2 = 2nd gang that this crime is afiliated with ( optional )
--	nMinFreaks = Minimum number of gang members for gang 1 ( optional )
--	nMinGangMembers2 = Minimum number of gang members for gang 2 ( optional )
--	nMaxFreaks = Maximum number of gang members for gang 1 ( optional )
--	nMaxGangMembers2 = Maximum number of gang members for gang 2 ( optional )
--	sNPCSpawnPointNameBase = Base NPC spawn point for this instance ( optional, derived from sInstanceName by appending "_NPC_SpawnPoint_" if not provided )
--	nNumNPCSpawnPoints1 = Number of spawn points for gang 1 choose from when spawning gang members ( optional )
--	nNumNPCSpawnPoints2 = Number of spawn points for gang 2 choose from when spawning gang members ( optional )
--	nSpawnProbability = Percentage probability of spawning ( optional )
----------------------------------------------------------------------


require "System\\State"
require "State\\Crime\\SGFreakEscape\\SGFreakEscape"


namespace ("SGFreakEscapeType")

SGFreakEscapeType = Create (State,
{
	sStateName = "SGFreakEscapeType",
	nMaxActiveInstances = 1,
})


-- This function should run a script that will provide the SGFreakEscape.atCrimeDetails
function SGFreakEscapeType:RunConfigScript (sConfigScriptName)

	-- Run the script to set up the crime details
	assert (sConfigScriptName and string.len (sConfigScriptName) > 0)
	RunScript (sConfigScriptName)

	-- Register all instances with the manager
	RunScript ("Config\AmbientCrimes\DefaultAI.SGFreakEscape.lua")
	for nIndex = 1, table.getn (SGFreakEscape.atCrimeDetails) do
		AmbientCrimeManager.RegisterNewInstance("SGFreakEscape",
												SGFreakEscape.atCrimeDetails[nIndex].sInstanceName,
												self:RetSpawnPointName (nIndex))
	end
end


function SGFreakEscapeType:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Default parameters
	self.tDefaultParameters = CreateReadOnly
	{
		tGang1 =				tMuchachos,
		tGang2 =				tMob,
		nMinFreaks       =		2,
		nMinGangMembers2 =		5,
		nMaxFreaks      =		2,
		nMaxGangMembers2 =		5,
		nNumNPCSpawnPoints1 =	5,
		nNumNPCSpawnPoints2 =	5,
		nSpawnProbability =		100,
	}

	-- Internal state data
	self.nNumActiveInstances = 0
end


function SGFreakEscapeType:CanSpawnInstance  (sInstanceName)
	-- Don't allow creation if we've already got enough of these crimes active
	if self.nNumActiveInstances >= self.nMaxActiveInstances then
		return false
	end

	-- Probability
	for nIndex = 1, table.getn (SGFreakEscape.atCrimeDetails) do
		if sInstanceName == SGFreakEscape.atCrimeDetails[nIndex].sInstanceName then
			-- Get probability index ( 0 to 100 )
			local nProb = self.tDefaultParameters.nSpawnProbability
			if SGFreakEscape.atCrimeDetails[nIndex].nSpawnProbability then
				nProb = SGFreakEscape.atCrimeDetails[nIndex].nSpawnProbability
			end

-- removed gang influence for m17 (pkg 2/9/05 )
--			-- Factor in gang influence from gang 1 ( 0 to 1 )
--			local tGang1 = self:RetGang1 (nIndex)
--			assert (tGang1)
--			local tSpawnPoint = cInfo.FindInfoByName (self:RetSpawnPointName (nIndex))
--			assert (tSpawnPoint)
--			local nGangInfluence = tGang1:RetInfluence (tSpawnPoint:RetPosition ())
--			nProb = nProb * nGangInfluence

			-- Perform the test
			if cAIPlayer.Rand (0, 100) >= nProb then
				return false
			end
			break
		end
	end

	-- All tests passed so let's say that we are happy to spawn this instance
	return true
end


function SGFreakEscapeType:CreateInstance (sInstanceName)
	local bWasSpawned = false
	
	-- Find the parameters for this particular instance
	for nIndex = 1, table.getn (SGFreakEscape.atCrimeDetails) do
		if sInstanceName == SGFreakEscape.atCrimeDetails[nIndex].sInstanceName then

			-- Create a parameter table
			local tParameters = {}

			-- Copy in our unique names
			tParameters.sInstanceName =	SGFreakEscape.atCrimeDetails[nIndex].sInstanceName

			-- Load up default or instance specific parameters
			tParameters.sSpawnPointName = self:RetSpawnPointName (nIndex)
			tParameters.tGang1 = self:RetGang1 (nIndex)
			tParameters.tGang2 = self:RetGang2 (nIndex)
			
			-- Figure out how many gang members we will spawn
			local nMinGangMembers
			local nMaxGangMembers

			-- Gang 1
			if SGFreakEscape.atCrimeDetails[nIndex].nMinFreaks then
				nMinGangMembers = SGFreakEscape.atCrimeDetails[nIndex].nMinFreaks
			else
				nMinGangMembers = self.tDefaultParameters.nMinFreaks
			end
			if SGFreakEscape.atCrimeDetails[nIndex].nMaxFreaks then
				nMaxGangMembers = SGFreakEscape.atCrimeDetails[nIndex].nMaxFreaks
			else
				nMaxGangMembers = self.tDefaultParameters.nMaxFreaks
			end
			tParameters.nGangMembers1 = cAIPlayer.Rand (nMinGangMembers, nMaxGangMembers)

			-- Gang 2
			if SGFreakEscape.atCrimeDetails[nIndex].nMinGangMembers2 then
				nMinGangMembers = SGFreakEscape.atCrimeDetails[nIndex].nMinGangMembers2
			else
				nMinGangMembers = self.tDefaultParameters.nMinGangMembers2
			end
			if SGFreakEscape.atCrimeDetails[nIndex].nMaxGangMembers2 then
				nMaxGangMembers = SGFreakEscape.atCrimeDetails[nIndex].nMaxGangMembers2
			else
				nMaxGangMembers = self.tDefaultParameters.nMaxGangMembers2
			end
			tParameters.nGangMembers2 = cAIPlayer.Rand (nMinGangMembers, nMaxGangMembers)
			
			-- Spawn points
			tParameters.sNPCSpawnPointNameBase = self:RetNPCSpawnPointNameBase (nIndex)
			if SGFreakEscape.atCrimeDetails[nIndex].nNumNPCSpawnPoints1 then
				tParameters.nNumNPCSpawnPoints1 = SGFreakEscape.atCrimeDetails[nIndex].nNumNPCSpawnPoints1
			else
				tParameters.nNumNPCSpawnPoints1 = self.tDefaultParameters.nNumNPCSpawnPoints1
			end
			if SGFreakEscape.atCrimeDetails[nIndex].nNumNPCSpawnPoints2 then
				tParameters.nNumNPCSpawnPoints2 = SGFreakEscape.atCrimeDetails[nIndex].nNumNPCSpawnPoints2
			else
				tParameters.nNumNPCSpawnPoints2 = self.tDefaultParameters.nNumNPCSpawnPoints2
			end

			-- Now spawn the instance and pass in our parameter table
			local MyInstance = AmbientCrimeManager.NewInstance (sInstanceName)
			assert (MyInstance)
			MyInstance:SetState (SGFreakEscape.SGFreakEscape)
			MyInstance:RetState():Construct (tParameters)
			
			self.nNumActiveInstances = self.nNumActiveInstances + 1
			assert (self.nNumActiveInstances <= table.getn (SGFreakEscape.atCrimeDetails))

			bWasSpawned = true
			break
		end
	end
	
	assert (bWasSpawned == true)
end


function SGFreakEscapeType:DestroyInstance (sInstanceName)
	self.nNumActiveInstances = self.nNumActiveInstances - 1
	assert (self.nNumActiveInstances >= 0)
end


function SGFreakEscapeType:RetSpawnPointName (nIndex)
	local sSpawnPointName
	
	if SGFreakEscape.atCrimeDetails[nIndex].sSpawnPointName then
		-- Spawn point was explicity named
		sSpawnPointName = SGFreakEscape.atCrimeDetails[nIndex].sSpawnPointName
	else
		-- Spawn point was not explicitly named so derive it
		sSpawnPointName = SGFreakEscape.atCrimeDetails[nIndex].sInstanceName .. "_Position"
	end
	
	return sSpawnPointName
end


function SGFreakEscapeType:RetNPCSpawnPointNameBase (nIndex)
	local sSpawnPointName
	
	if SGFreakEscape.atCrimeDetails[nIndex].sNPCSpawnPointNameBase then
		-- Spawn point base name was explicity named
		sNPCSpawnPointNameBase = SGFreakEscape.atCrimeDetails[nIndex].sNPCSpawnPointNameBase
	else
		-- Spawn point base name was not explicitly named so derive it
		sNPCSpawnPointNameBase = SGFreakEscape.atCrimeDetails[nIndex].sInstanceName .. "_NPC_SpawnPoint_"
	end
	
	return sNPCSpawnPointNameBase
end


function SGFreakEscapeType:RetGang1 (nIndex)
	local tGang1
	
	if SGFreakEscape.atCrimeDetails[nIndex].tGang1 then
		-- Gang was explicity named
		tGang1 = SGFreakEscape.atCrimeDetails[nIndex].tGang1
	else
		-- Gang was not explicitly named so return default
		tGang1 = self.tDefaultParameters.tGang1
	end
	
	return tGang1
end


function SGFreakEscapeType:RetGang2 (nIndex)
	local tGang2
	
	if SGFreakEscape.atCrimeDetails[nIndex].tGang2 then
		-- Gang was explicity named
		tGang2 = SGFreakEscape.atCrimeDetails[nIndex].tGang2
	else
		-- Gang was not explicitly named so return default
		tGang2 = self.tDefaultParameters.tGang2
	end
	
	return tGang2
end
