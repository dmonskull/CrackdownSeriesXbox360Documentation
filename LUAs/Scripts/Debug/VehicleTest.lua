----------------------------------------------------------------------
-- Name: VehicleTest Script
--	Description: 
-- 1. Spawns an NPC and a vehicle
-- 2. The NPC walks towards the vehicle
-- 3. The NPC enters the vehicle through door nDoor
-- 4. The NPC does nothing for 2 seconds
-- 5. The NPC exits the vehicle
-- If bRepeat is true then this behaviour repeats with the next door
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Vehicles\\MoveToAndEnterVehicle"
require "State\\NPC\\Action\\Vehicles\\ExitVehicle"
require "State\\NPC\\Action\\Idle\\Wait"


VehicleTest = Create (TargetState,
{
	sStateName = "VehicleTest",
	nDoor = 1,
	bRepeat = true,
})

PreDelay = Create (Wait,
{
	sStateName = "PreDelay",
})

function VehicleTest:OnEnter ()
	TargetState.OnEnter (self)
	AILib.Emit ("Moving to and entering vehicle")
	self:PushState (Create (PreDelay,
	{
		nWaitTime = 2,
	}))
end

function VehicleTest:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (PreDelay) then
	
		self:ChangeState (Create (MoveToAndEnterVehicle,
		{
			nSelectedDoor = self.nDoor,
		}))
		return true
		
	elseif tState:IsA (MoveToAndEnterVehicle) then

		if tState:Success () then
			AILib.Emit ("Waiting 2 seconds")
			self:ChangeState (Create (Wait, 
			{
				nWaitTime = 2,
			}))			
		else
			AILib.Emit ("Failed to enter vehicle")
		end
		return true

	elseif tState:IsA (Wait) then

		AILib.Emit ("Exiting vehicle")
		self:ChangeState (Create (ExitVehicle, {}))
		return true

	elseif tState:IsA (ExitVehicle) then

		if tState:Success () then
			AILib.Emit ("VehicleTest completed successfully!")
		else
			AILib.Emit ("Failed to exit vehicle")
		end
		if self.bRepeat then
			self.nDoor = self.nDoor + 1
			if self.nDoor == 3 then
				self.nDoor = 1
			end
			self:ChangeState (Create (PreDelay,
			{
				nWaitTime = 2,
			}))
		else
			self:Finish ()
		end
		return true

	end
	return TargetState.OnActiveStateFinished (self)

end

local tVehicle = SpawnInFrontOfPlayer ("CIV_001_Saloon", 20)
local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
tNPC:SetState (Create (VehicleTest, 
{
	tTarget = tVehicle,
}))
