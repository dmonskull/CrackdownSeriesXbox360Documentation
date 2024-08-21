----------------------------------------------------------------------
-- Name: PrimaryFire State
--	Description: Stand still and shoot continuously at the current target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

PrimaryFire = Create (TargetState, 
{
	sStateName = "PrimaryFire",
	bSuccess = false,
})

function PrimaryFire:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to Primary Fire finished event
	self.nPrimaryFireFinishedID = self:Subscribe (eEventType.AIE_PRIMARY_FIRE_FINISHED, self.tHost)

	self:OnResume ()
end

function PrimaryFire:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Go into PrimaryFire state
	self.tHost:PrimaryFire ()
end

function PrimaryFire:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function PrimaryFire:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function PrimaryFire:OnEvent (tEvent)

	if tEvent:HasID (self.nPrimaryFireFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function PrimaryFire:Success ()
	return self.bSuccess
end
