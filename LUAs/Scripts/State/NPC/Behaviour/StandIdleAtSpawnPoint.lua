----------------------------------------------------------------------
-- Name: StandIdleAtSpawnPoint State
--	Description: Move towards a spawn point and then stand idle there
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Behaviour\\StandIdle"
require "State\\NPC\\Behaviour\\MoveToSpawnPoint"

StandIdleAtSpawnPoint = Create (State, 
{
	sStateName = "StandIdleAtSpawnPoint",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
})

function StandIdleAtSpawnPoint:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- If the spawn point is specified by name then get a pointer to it
	if self.sSpawnPointName then
		self.tSpawnPoint = cInfo.FindInfoByName (self.sSpawnPointName)
	end

	assert (self.tSpawnPoint)

	self:PushState (Create (MoveToSpawnPoint,
	{
		tSpawnPoint = self.tSpawnPoint,
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
	}))
end

function StandIdleAtSpawnPoint:OnActiveStateFinished ()

	if self:IsInState (MoveToSpawnPoint) then

		self:ChangeState (Create (StandIdle, {}))
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end
