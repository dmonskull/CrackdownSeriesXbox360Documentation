----------------------------------------------------------------------
-- Name: Traffic State
--	Description: Vehicle driving around state
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Pedestrian"
require "State\\NPC\\Action\\Vehicles\\DriveTrafficVehicle"

Traffic = Create (Pedestrian, 
{
	sStateName = "Traffic",
})

function Traffic:CreateInitialState ()
	return self:CreateTrafficState ()
end

function Traffic:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if self:InTrafficState () then

		-- Kicked out of vehicle!
		self:ChangeState (self:CreateFleeState (tState.tVehicle))
		return true

	end

	-- Call parent
	return Pedestrian.OnActiveStateFinished (self)
end

----------------------------------------------------------------------
-- Traffic State
----------------------------------------------------------------------

function Traffic:CreateTrafficState ()
	return Create (DriveTrafficVehicle, {})
end

function Traffic:InTrafficState ()
	return self:IsInState (DriveTrafficVehicle)
end

----------------------------------------------------------------------
-- Length of view cone
----------------------------------------------------------------------

function Traffic:RetViewingDistance ()

	if self:InTrafficState () then
		return 0
	end

	-- Call parent
	return Pedestrian.RetViewingDistance (self)
end
