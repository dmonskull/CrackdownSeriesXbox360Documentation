----------------------------------------------------------------------
-- Name: PickUp State
--	Description: Picks up a targeted object from the ground
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

PickUp = Create (TargetState, 
{
	sStateName = "PickUp",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nObjectTargetingChecks,
	bSuccess = false,
})

function PickUp:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to pick up finished event
	self.nPickUpFinishedID = self:Subscribe (eEventType.AIE_PICKUP_FINISHED, self.tHost)

	self:OnResume ()
end

function PickUp:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Are we already carrying this object?
	if self.tHost:RetCarriedObject () == self.tTargetInfo:RetTarget () then
		self.bSuccess = true
		self:Finish ()
	else
		-- Go into the pick up brain state
		if self.tTargetInfo:CanPickUpTarget () then
			self.tHost:PickUp ()
		else
			self.bSuccess = false
			self:Finish ()
		end
	end
end

function PickUp:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function PickUp:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function PickUp:OnEvent (tEvent)

	if tEvent:HasID (self.nPickUpFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function PickUp:Success ()
	return self.bSuccess
end
