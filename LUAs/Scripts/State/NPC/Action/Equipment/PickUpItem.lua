----------------------------------------------------------------------
-- Name: PickUpItem State
-- Description: Picks up a targeted equipment item from the ground
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

PickUpItem = Create (TargetState, 
{
	sStateName = "PickUpItem",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nObjectTargetingChecks,
	bSuccess = false,
})

function PickUpItem:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to pick up item finished event
	self.nPickUpItemFinishedID = self:Subscribe (eEventType.AIE_PICKUP_ITEM_FINISHED, self.tHost)

	self:OnResume ()
end

function PickUpItem:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Are we already carrying this object?
	if self.tHost:RetCurrentPrimaryEquipment () == self.tTargetInfo:RetTarget () or
		self.tHost:RetCurrentSecondaryEquipment () == self.tTargetInfo:RetTarget () then
		self.bSuccess = true
		self:Finish ()
	else
		-- Go into the pick up brain state
		if self.tTargetInfo:CanPickUpTarget () then
			self.tHost:PickUpItem ()
		else
			self.bSuccess = false
			self:Finish ()
		end
	end
end

function PickUpItem:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function PickUpItem:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function PickUpItem:OnEvent (tEvent)

	if tEvent:HasID (self.nPickUpItemFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function PickUpItem:Success ()
	return self.bSuccess
end
