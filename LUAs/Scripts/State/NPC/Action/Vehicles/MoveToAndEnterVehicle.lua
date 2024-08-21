----------------------------------------------------------------------
-- Name: MoveToAndEnterVehicle State
-- Description: Moves towards a vehicle and then enters it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Vehicles\\MoveToVehicle"
require "State\\NPC\\Action\\Vehicles\\EnterVehicle"

MoveToAndEnterVehicle = Create (TargetState, 
{
	sStateName = "MoveToAndEnterVehicle",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nVehicleTargetingChecks,
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
	nSelectedDoor = 1,
})

function MoveToAndEnterVehicle:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:PushState (Create (MoveToVehicle,
	{
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
		nSelectedDoor = self.nSelectedDoor,
	}))

end

function MoveToAndEnterVehicle:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	if tState:IsA (MoveToVehicle) then

		if tState:Success () then
		
			-- Reached the vehicle, now try and enter it
			self:ChangeState (Create (EnterVehicle, {}))
			
		else
		
			-- Failed to reach the vehicle
			self.bSuccess = false
			self:Finish ()
			
		end
		return true

	elseif tState:IsA (EnterVehicle) then

		self.bSuccess = tState:Success ()
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function MoveToAndEnterVehicle:Success ()
	return self.bSuccess
end
