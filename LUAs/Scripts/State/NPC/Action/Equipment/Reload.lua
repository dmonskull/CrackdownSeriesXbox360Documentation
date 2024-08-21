----------------------------------------------------------------------
-- Name: Reload State
--	Description: Reload the current weapon (will face the last known position 
-- of the current target while doing so if there is one)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Reload = Create (TargetState, 
{
	sStateName = "Reload",
	bTargetMandatory = false,
	bSuccess = false,
})

function Reload:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to reload finished event
	self.nReloadFinishedID = self:Subscribe (eEventType.AIE_RELOAD_FINISHED, self.tHost)

	self:OnResume ()
end

function Reload:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Check that I have a weapon, otherwise there is nothing to reload
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () then

		-- Check if the ammo in the weapon is less than the maximum
		-- if not it doesn't need reloading and we just finish immediately
		if self.tHost:RetCurrentPrimaryEquipment ():NeedsReload () then

			-- Go into the reload brain state
			self.tHost:Reload ()

		else
			self.bSuccess = true
			self:Finish ()
		end

	else
		self.bSuccess = false
		self:Finish ()
	end

end

function Reload:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Reload:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Reload:OnEvent (tEvent)

	if tEvent:HasID (self.nReloadFinishedID) then
		
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return State.OnEvent (self, tEvent)
end

function Reload:Success ()
	return self.bSuccess
end
