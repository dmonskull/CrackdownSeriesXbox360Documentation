----------------------------------------------------------------------
-- Name: EquipItem State
--	Description: Changes the current weapon (will face the last known position 
-- of the current target while doing so if there is one)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

EquipItem = Create (TargetState, 
{
	sStateName = "EquipItem",
	bTargetMandatory = false,
	bSuccess = false,
})

function EquipItem:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to store item finished event
	self.nEquipItemFinishedID = self:Subscribe (eEventType.AIE_EQUIP_ITEM_FINISHED, self.tHost)

	self:OnResume ()
end

function EquipItem:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Check parameters
	assert (self.tEquipment)

	if self.tHost:IsCurrentPrimaryEquipmentEquiped () and
		self.tHost:RetCurrentPrimaryEquipment () == self.tEquipment then
		-- I'm already holding that item, just finish
		self.bSuccess = true
		self:Finish ()
	else
		-- Go into the equip item brain state
		self.tHost:EquipItem (self.tEquipment)
	end
end

function EquipItem:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function EquipItem:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function EquipItem:OnEvent (tEvent)

	if tEvent:HasID (self.nEquipItemFinishedID) then

		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function EquipItem:Success ()
	return self.bSuccess
end
