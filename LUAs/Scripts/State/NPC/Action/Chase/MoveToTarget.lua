----------------------------------------------------------------------
-- Name: MoveToTarget State
--	Description: Move towards the current target, finish when we get there
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Chase\\Chase"

MoveToTarget = Create (Chase, 
{
	sStateName = "MoveToTarget",
	bSuccess = false,
})

function MoveToTarget:OnEnter ()
	-- Call parent
	Chase.OnEnter (self)

	-- Subscribe events
	self.nReachedDestinationID = self:Subscribe(eEventType.AIE_REACHED_DESTINATION, self.tHost)
end

function MoveToTarget:OnEvent (tEvent)
	
	-- We have reached the target
	if tEvent:HasID (self.nReachedDestinationID) then

		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true

	end

	return Chase.OnEvent (self, tEvent)
end

function MoveToTarget:Success ()
	return self.bSuccess
end
