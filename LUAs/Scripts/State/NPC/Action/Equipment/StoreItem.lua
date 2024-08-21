----------------------------------------------------------------------
-- Name: StoreItem State
--	Description: Stores the current weapon (will face the last known position 
-- of the current target while doing so if there is one)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

StoreItem = Create (TargetState, 
{
	sStateName = "StoreItem",
	bTargetMandatory = false,
	bSuccess = false,
})

function StoreItem:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to store item finished event
	self.nStoreItemFinishedID = self:Subscribe (eEventType.AIE_STORE_ITEM_FINISHED, self.tHost)
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	self:OnResume ()
end

function StoreItem:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	if self.tHost:IsCurrentPrimaryEquipmentEquiped () then
		-- Add a timeout for storing weapons
		-- This is a safeguard for when the store item fails ( pkg )
		self.nTimerID = self:AddTimer (5, false)

		-- Go into the store item brain state
		self.tHost:StoreItem ()
	else
		-- I'm not holding any equipment, just finish
		self.bSuccess = true
		self:Finish ()
	end
end

function StoreItem:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function StoreItem:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function StoreItem:OnEvent (tEvent)

	if tEvent:HasID (self.nStoreItemFinishedID) then
		
		self.bSuccess = true
		self:Finish ()
		return true
		
	end

	-- This is a safeguard for when the store item fails ( pkg )
	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self.bSuccess = true
		self:Finish ()
		return true

	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function StoreItem:Success ()
	return self.bSuccess
end
