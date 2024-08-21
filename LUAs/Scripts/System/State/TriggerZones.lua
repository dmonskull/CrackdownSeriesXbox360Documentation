----------------------------------------------------------------------
-- Name: Trigger Zones
-- Description: Extends the State class - allows a state to initialise
-- trigger zones and records all trigger zones it set up in a table so 
-- they can be terminated automatically
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:RetTriggerZone (sName)
	-- Get Zone manager
	local tZoneManager = cZoneManager.RetZoneManager ()
	assert (tZoneManager)

	-- Get trigger zone
	local tTriggerZone = tZoneManager:RetNamedAITriggerZone (sName)
	return tTriggerZone
end

function State:InitTriggerZone (sName)
	if not self.aTriggerZones then
		self.aTriggerZones = {}
	end

	-- Get trigger zone
	local tTriggerZone = self:RetTriggerZone (sName)
	assert (tTriggerZone)
	assert (not tTriggerZone:IsInited ())

	-- Initialise the trigger zone, so it will now detect objects
	tTriggerZone:Init ()

	-- save it to the array
	self.aTriggerZones[tTriggerZone] = sName

	return tTriggerZone
end

function State:TermTriggerZone (tTriggerZone)
	assert(tTriggerZone)
	assert(tTriggerZone:IsInited())

	assert(self.aTriggerZones)
	assert(self.aTriggerZones[tTriggerZone])

	-- Terminate trigger zone, so it no longer detects objects
	tTriggerZone:Term ()

	self.aTriggerZones[tTriggerZone] = nil
end

function State:TermAllTriggerZones ()
	if self.aTriggerZones then
		for tTriggerZone in pairs (self.aTriggerZones) do
			self:TermTriggerZone (tTriggerZone)
		end
	end
end
