----------------------------------------------------------------------
-- Name: ChaseAndReload State
--	Description: Reload whilst moving towards the current target.  Finishes
-- when the reload finishes.
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

ChaseAndReload = Create (TargetState, 
{
	sStateName = "ChaseAndReload",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
})

function ChaseAndReload:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to reload finished event
	self.nReloadFinishedID = self:Subscribe (eEventType.AIE_RELOAD_FINISHED, self.tHost)

	self:OnResume ()
end

function ChaseAndReload:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Check that I have a weapon, otherwise there is nothing to reload
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () then

		-- Check if the ammo in the weapon is less than the maximum
		-- if not it doesn't need reloading and we just finish immediately
		if self.tHost:RetCurrentPrimaryEquipment ():NeedsReload () then		

			-- Set speed
			self.tHost:SetMovementType (self.nMovementType)
	
			-- Set priority
			self.tHost:SetMovementPriority (self.nMovementPriority)	
	
			-- Go into the chase and reload brain state
			self.tHost:ChaseAndReload ()

		else
			self.bSuccess = true
			self:Finish ()
		end

	else
		self.bSuccess = false
		self:Finish ()
	end

end

function ChaseAndReload:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function ChaseAndReload:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function ChaseAndReload:OnEvent (tEvent)
	
	-- Finished reloading
	if tEvent:HasID (self.nReloadFinishedID) then

		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true

	end

	return TargetState.OnEvent (self, tEvent)
end

function ChaseAndReload:Success ()
	return self.bSuccess
end
