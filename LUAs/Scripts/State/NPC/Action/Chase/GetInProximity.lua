----------------------------------------------------------------------
-- Name: GetInProximity State
--	Description: Move to within a specified radius of the current target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Chase\\Chase"

GetInProximity = Create (Chase, 
{
	sStateName = "GetInProximity",
	bSuccess = false,
	nRadius = 3,
})

function GetInProximity:OnEnter ()
	-- Check parameters
	assert (self.nRadius)

	-- Call parent
	Chase.OnEnter (self)

	-- Subscribe to events
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)
	self.nReachedDestinationID = self:Subscribe (eEventType.AIE_REACHED_DESTINATION, self.tHost)
end

function GetInProximity:OnResume ()
	-- Call parent
	Chase.OnResume (self)

	-- Set up proximity check
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nRadius)

	-- Target is already in proximity so just finish
	if self:IsTargetInProximity (self.nProximityCheckID) then
		self.bSuccess = true
		self:Finish ()
	end

end

function GetInProximity:OnPause ()
	-- Delete the proximity check
	self:DeleteProximityCheck (self.nProximityCheckID)
	
	-- Call parent
	Chase.OnPause (self)
end

function GetInProximity:OnEvent (tEvent)
	
	-- Target is now in proximity
	if tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self.bSuccess = true
		self:Finish ()
		return true

	-- We have reached the last known target position, but the target is not in proximity
	elseif tEvent:HasID (self.nReachedDestinationID) then

		self.bSuccess = false
		self:Finish ()
		return true

	end

	return Chase.OnEvent (self, tEvent)
end

function GetInProximity:Success ()
	return self.bSuccess
end
