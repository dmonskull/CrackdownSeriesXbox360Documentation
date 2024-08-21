----------------------------------------------------------------------
-- Name: RadioGangZone State
--	Description: Gang zone for the hillside housing area
-- Gang influence becomes greater at night time
-- Ownership changes to agency when Violetta Sanchez dies
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

RadioGangZone = Create (State, 
{
	sStateName = "RadioGangZone",
})

function RadioGangZone:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tRadioMission)

	-- Initialise control to muchachos
	self.tHost:SetGangInControl (tMuchachos)

	-- Set up mix of gangsters
	self.tHost:Clear ()

	self.tHost:AddPedestrian (0.5, "AIStreetSoldier5", "Config\\NPC\\StreetSoldierSpawnScript")
	self.tHost:AddPedestrian (0.5, "AIStreetSoldier2", "Config\\NPC\\StreetSoldierSpawnScript")

	self.tHost:AddDrivenVehicle (1.0, "G1_039_JapaneseCar", nil, "AIStreetSoldier5", "Config\\NPC\\GenericVehicleSpawnScript")


	-- Set gang influence according to time of day
	self:SetInfluence ()

	-- Subscribe events
	self.nDawnID = self:Subscribe (eEventType.AIE_TODDAWN, cTimeOfDay.RetTimeOfDayManager ())
	self.nDuskID = self:Subscribe (eEventType.AIE_TODDUSK, cTimeOfDay.RetTimeOfDayManager ())
	self.nRadioEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tRadioMission)
end

function RadioGangZone:OnEvent (tEvent)

	-- It's day time - decrease the gang influence
	if tEvent:HasID (self.nDawnID) then

		self:SetInfluence ()
		return true

	-- It's night time - increase the gang influence
	elseif tEvent:HasID (self.nDuskID) then

		self:SetInfluence ()
		return true

	-- The Hillside Housing mission has been completed - set control to the agency
	elseif tEvent:HasID (self.nRadioEventID) and tEvent:HasCustomEventID ("StateFinished") then

		-- Change control to agency
		self.tHost:SetGangInControl (tAgency)

		-- Set up mix of agency enforcers
		--self.tHost:Clear ()
		--self.tHost:AddPedestrian (1, "AIStreetSoldier5", "Config\\NPC\\AgencyEnforcerSpawnScript")

		self:SetInfluence ()
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function RadioGangZone:SetInfluence ()

	if self.tHost:RetGangInControl () == tAgency then

		-- Agency enforcers are always just a small percentage of the population
		self.tHost:SetInfluence (0.1)

	else

		-- Muchachos have more influence at night
		local tTimeOfDay = cTimeOfDay.RetTimeOfDayManager ()
	
		if tTimeOfDay:IsDayTime () then
			self.tHost:SetInfluence (0.5)
		else
			self.tHost:SetInfluence (0.75)
		end

	end

end