----------------------------------------------------------------------
-- Name: Ambient Crimes
-- Description: Extends the State class - allows a state to set up ambient
-- crime types and records all of them in a table so they can be
-- deleted automatically, thus avoiding memory leaks
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:NewAmbientCrimeType (sTypeName)
	-- Create a new generic mission
	if not self.tAmbientCrimeTypes then
		self.tAmbientCrimeTypes = {}
	end

	local tAmbientCrimeType = AmbientCrimeManager.NewType (sTypeName)
	self.tAmbientCrimeTypes[tAmbientCrimeType] = tAmbientCrimeType
	return tAmbientCrimeType
end

function State:DeleteAmbientCrimeType (tAmbientCrimeType)
	assert(self.tAmbientCrimeTypes)
	assert(self.tAmbientCrimeTypes[tAmbientCrimeType])
	self.tAmbientCrimeTypes[tAmbientCrimeType] = nil
	AmbientCrimeManager.DeleteType (tAmbientCrimeType)
end

function State:DeleteAllAmbientCrimeTypes ()
	if self.tAmbientCrimeTypes then
		for tAmbientCrimeType in pairs (self.tAmbientCrimeTypes) do
			self:DeleteAmbientCrimeType (tAmbientCrimeType)
		end
	end
end
