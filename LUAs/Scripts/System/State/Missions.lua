----------------------------------------------------------------------
-- Name: Missions
-- Description: Extends the State class - allows a state to set up missions
-- and records all missions it set up in a table so they can be
-- deleted automatically, thus avoiding memory leaks
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:NewMission (sMissionName, tGangInfo, sSpawnPointName)
	-- Create a new generic mission
	if not self.tMissions then
		self.tMissions = {}
	end

	local tMission = MissionManager.NewMission (sMissionName, tGangInfo, sSpawnPointName)
	self.tMissions[tMission] = tMission
	return tMission
end

function State:NewDistributionMission (sMissionName, tGangInfo, sSpawnPointName, nMaxPool, nMaxRespawnRate)
	-- Create a new guard distribution mission
	if not self.tMissions then
		self.tMissions = {}
	end

	local tMission = MissionManager.NewDistributionMission (sMissionName, tGangInfo, sSpawnPointName, nMaxPool, nMaxRespawnRate)
	self.tMissions[tMission] = tMission
	return tMission
end

function State:NewAttackSquadMission (sMissionName, tGangInfo, sSpawnPointName)
	-- Create a new attack squad mission
	if not self.tMissions then
		self.tMissions = {}
	end

	local tMission = MissionManager.NewAttackSquadMission (sMissionName, tGangInfo, sSpawnPointName)
	self.tMissions[tMission] = tMission
	return tMission
end

function State:DeleteMission (tMission)
	assert(self.tMissions)
	assert(self.tMissions[tMission])
	self.tMissions[tMission] = nil
	MissionManager.DeleteMission (tMission)
end

function State:DeleteAllMissions ()
	if self.tMissions then
		for tMission in pairs (self.tMissions) do
			self:DeleteMission (tMission)
		end
	end
end

function State:NewRaceMission (sMissionName, tGangInfo, sSpawnPointName)
	-- Create a new guard distribution mission
	if not self.tMissions then
		self.tMissions = {}
	end

	local tMission = MissionManager.NewRaceMission (sMissionName, tGangInfo, sSpawnPointName)
	self.tMissions[tMission] = tMission
	return tMission
end

