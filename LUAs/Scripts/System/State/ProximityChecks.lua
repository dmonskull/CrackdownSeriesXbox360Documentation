----------------------------------------------------------------------
-- Name: Proximity Checks
--	Description: Extends the State class - allows a state to set up proximity
-- checks, and records all proximity checks it set up in a table so they can be
-- deleted automatically, thus avoiding memory leaks
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:AddProximityCheck (tSource, tTarget, nDistance)
	if not self.aProximityCheckIDs then
		self.aProximityCheckIDs = {}
	end

	local tProximityCheckManager = cProximityCheckManager.RetProximityCheckManager ()
	assert (tProximityCheckManager)

	local nProximityCheckID = tProximityCheckManager:AddProximityCheck (tSource, tTarget, nDistance)
	self.aProximityCheckIDs [nProximityCheckID] = nProximityCheckID
	return nProximityCheckID
end

function State:DeleteProximityCheck (nProximityCheckID)
	assert(self.aProximityCheckIDs)
	local tProximityCheckManager = cProximityCheckManager.RetProximityCheckManager ()
	assert (tProximityCheckManager)

	--assert(self.aProximityCheckIDs [nProximityCheckID] == nProximityCheckID)
	tProximityCheckManager:DeleteProximityCheck (nProximityCheckID)

	self.aProximityCheckIDs [nProximityCheckID] = nil
end

function State:DeleteAllProximityChecks ()
	if self.aProximityCheckIDs then
		for nProximityCheckID in pairs (self.aProximityCheckIDs) do
			self:DeleteProximityCheck (nProximityCheckID)
		end
	end
end

function State:IsTargetInProximity (nProximityCheckID)
	local tProximityCheckManager = cProximityCheckManager.RetProximityCheckManager ()
	assert (tProximityCheckManager)

	return tProximityCheckManager:IsTargetInProximity (nProximityCheckID)
end

