----------------------------------------------------------------------
-- Name: SecondaryFire State
--	Description: Stand still and use secondary fire
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

SecondaryFire = Create (TargetState, 
{
	sStateName = "SecondaryFire",
	bSuccess = false,
})

function SecondaryFire:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to Secondary Fire finished event
	self.nSecondaryFireFinishedID = self:Subscribe (eEventType.AIE_SECONDARY_FIRE_FINISHED, self.tHost)

	self:OnResume ()
end

function SecondaryFire:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into the SecondaryFire brain state
	self.tHost:SecondaryFire ()
end

function SecondaryFire:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function SecondaryFire:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function SecondaryFire:OnEvent (tEvent)

	if tEvent:HasID (self.nSecondaryFireFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function SecondaryFire:Success ()
	return self.bSuccess
end
