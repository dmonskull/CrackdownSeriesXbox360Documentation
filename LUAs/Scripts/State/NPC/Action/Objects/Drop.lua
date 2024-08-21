----------------------------------------------------------------------
-- Name: Drops State
--	Description: Drops the object we are currently holding (will face the last 
-- known position of the current target while doing so if there is one)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Drop = Create (TargetState, 
{
	sStateName = "Drop",
	bTargetMandatory = false,
	bSuccess = false,
})

function Drop:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to drop finished event
	self.nDropFinishedID = self:Subscribe (eEventType.AIE_DROP_FINISHED, self.tHost)

	self:OnResume ()
end

function Drop:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	if self.tHost:RetCarriedObject () then
		-- Go into the drop brain state
		self.tHost:Drop ()
	else
		-- Finish and set success to true, since at least we are not carrying anything (?)
		self.bSuccess = true
		self:Finish ()
	end
end

function Drop:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Drop:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Drop:OnEvent (tEvent)

	if tEvent:HasID (self.nDropFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Drop:Success ()
	return self.bSuccess
end
