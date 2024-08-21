----------------------------------------------------------------------
-- Name: GetLineOfSight State
--	Description: Run towards the last known target position until the target
-- becomes visible
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Chase\\Chase"

GetLineOfSight = Create (Chase, 
{
	sStateName = "GetLineOfSight",
	bSuccess = false,
})

function GetLineOfSight:OnEnter ()
	-- Call parent
	Chase.OnEnter (self)

	-- Subscribe to events
	self.nTargetAppearedID = self:Subscribe (eEventType.AIE_TARGET_APPEARED, self.tTargetInfo)
	self.nReachedDestinationID = self:Subscribe(eEventType.AIE_REACHED_DESTINATION, self.tHost)
end

function GetLineOfSight:OnResume ()
	-- Call parent
	Chase.OnResume (self)

	-- Target is already visible so just finish
	if self.tTargetInfo:IsTargetVisible () then
		self.bSuccess = true
		self:Finish ()
	end

end

function GetLineOfSight:OnEvent (tEvent)
	
	-- Target is no longer hidden
	if tEvent:HasID (self.nTargetAppearedID) then

		self.bSuccess = true
		self:Finish ()
		return true

	-- We have reached the last known target position, but the target is not visible
	elseif tEvent:HasID (self.nReachedDestinationID) then

		self.bSuccess = false
		self:Finish ()
		return true

	end

	return Chase.OnEvent (self, tEvent)
end

function GetLineOfSight:Success ()
	return self.bSuccess
end
