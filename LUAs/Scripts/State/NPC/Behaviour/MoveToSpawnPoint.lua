----------------------------------------------------------------------
-- Name: MoveToSpawnPoint State
--	Description: Moves to the position of a spawn point and then faces in
-- the direction of the spoint point orientation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Turn\\Turn"

MoveToSpawnPoint = Create (State, 
{
	sStateName = "MoveToSpawnPoint",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
})

function MoveToSpawnPoint:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- If the spawn point is specified by name then get a pointer to it
	if self.sSpawnPointName then
		self.tSpawnPoint = cInfo.FindInfoByName (self.sSpawnPointName)
	end

	assert (self.tSpawnPoint)

	self:PushState (Create (Move,
	{
		vDestination = self.tSpawnPoint:RetWalkPosition (self.tHost),
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
	}))
end

function MoveToSpawnPoint:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (Move) then

		if tState:Success () then

			-- Get the yaw from the orientation of the spawn point
			local nYaw = self.tSpawnPoint:RetHeading ()
	
			-- Turn to face the direction of the spawn point yaw
			-- (by targetting a position 10 metres away in the direction of the spawnpoint yaw)
			self:ChangeState (Create (Turn,
			{
				vTargetPosition = self.tHost:RetPosFromYaw (10, nYaw)
			}))

		else
			self.bSuccess = false
			self:Finish ()
		end
		return true

	elseif tState:IsA (Turn) then

		self.bSuccess = true
		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

function MoveToSpawnPoint:Success ()
	return self.bSuccess
end
