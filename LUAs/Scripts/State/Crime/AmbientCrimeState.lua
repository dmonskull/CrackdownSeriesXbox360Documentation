----------------------------------------------------------------------
-- Name: Ambient Crime State
-- Description: Base state for ambient crimes
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

AmbientCrimeState = Create (State, 
{
	sStateName = "AmbientCrimeState",
	bDeleteMissionObjects = true,
})

----------------------------------------------------------------------
-- SetDeleteMissionObjects - this sets a flag which indicates if, when the
-- crime state exits, we should delete any characters or props that are
-- owned by the state, or if we should just detach them from the crime
-- to be deleted by the activity volume
----------------------------------------------------------------------

function AmbientCrimeState:SetDeleteMissionObjects (bDeleteMissionObjects)
	self.bDeleteMissionObjects = bDeleteMissionObjects
	
	for i, tState in pairs (self.atStack) do
		tState:SetDeleteMissionObjects (bDeleteMissionObjects)
	end
end
