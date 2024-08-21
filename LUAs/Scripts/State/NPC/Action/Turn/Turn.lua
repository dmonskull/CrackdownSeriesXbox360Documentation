----------------------------------------------------------------------
-- Name: Turn State
--	Description: Turn to face the current target, finish when we are facing it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Turn = Create (TargetState, 
{
	sStateName = "Turn",
})

function Turn:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to rotate finished event
	self.nFacingTargetID = self:Subscribe (eEventType.AIE_FACING_TARGET, self.tTargetInfo)
	
	self:OnResume ()
end

function Turn:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into the Face brain state
	self.tHost:Face ()

	-- If we are already facing the target then just stop now
	if self.tTargetInfo:IsFacingTarget () then
		self:Finish ()
	end

end

function Turn:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Turn:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Turn:OnEvent (tEvent)

	if tEvent:HasID (self.nFacingTargetID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
