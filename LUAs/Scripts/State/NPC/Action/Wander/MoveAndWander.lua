----------------------------------------------------------------------
-- Name: MoveAndWander State
--	Description: Walk to the nearest sidewalk and then wander around aimlessly
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Wander\\Wander"

MoveAndWander = Create (State,{
	sStateName = "MoveAndWander",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bOnSideWalk = false,
})

function MoveAndWander:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Are we already on the sidewalk?
	if self.bOnSideWalk then

		-- Don't waste CPU time searching for the nearest pedestrian node
		self:PushState (Create (Wander, 
		{
			nMovementType = self.nMovementType,
			nMovementPriority = self.nMovementPriority,
			bOnSideWalk = self.bOnSideWalk,
		}))

	else

		-- Go to the nearest pedestrian node
		self:PushState (Create (Move,
		{
			vDestination = AILib.RetNearestPedestrianVertexPosition (self.tHost:RetPosition ()),
			nMovementType = self.nMovementType,
			nMovementPriority = self.nMovementPriority,
		}))

	end

end

function MoveAndWander:OnActiveStateFinished ()

	if self:IsInState (Move) then
	
		-- Wander around the pedestrian nodes
		self:ChangeState (Create (Wander, 
		{
			nMovementType = self.nMovementType,
			nMovementPriority = self.nMovementPriority,
			bOnSideWalk = false,
		}))
		return true

	elseif self:IsInState (Wander) then

		-- Wander agent failed - just stand around idle
		self:ChangeState (Create (Idle, {}))
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end
