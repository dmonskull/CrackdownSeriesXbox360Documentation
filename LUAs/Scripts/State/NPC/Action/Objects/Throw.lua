----------------------------------------------------------------------
-- Name: Throw State
--	Description: Stand still and throw carried object (not grenades - use 
-- SecondaryFire for that)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Throw = Create (TargetState, 
{
	sStateName = "Throw",
	bSuccess = false,
})

function Throw:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to Throw finished event
	self.nThrowFinishedID = self:Subscribe (eEventType.AIE_THROW_FINISHED, self.tHost)

	self:OnResume ()
end

function Throw:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into the Throw brain state
	self.tHost:Throw ()
end

function Throw:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Throw:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Throw:OnEvent (tEvent)

	if tEvent:HasID (self.nThrowFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Throw:Success ()
	return self.bSuccess
end
