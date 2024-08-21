----------------------------------------------------------------------
-- Name: WaitForProximity State
--	Description: Stand idle until an entity comes within a specified
-- distance of me
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Idle\\Idle"

WaitForProximity = Create (Idle, 
{
	sStateName = "WaitForProximity",
	nRadius = 3,
})

function WaitForProximity:OnEnter ()
	-- Check parameters
	assert (self.tEntity)

	-- Set up proximity check
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tEntity, self.nRadius)

	-- Subscribe to events
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)
	self.nTargetDeletedID = self:Subscribe (eEventType.AIE_OBJECT_DELETED, self.tEntity)

	-- Call parent
	Idle.OnEnter (self)
end

function WaitForProximity:OnResume ()
	-- Call parent
	Idle.OnResume (self)

	-- Target is already in proximity so just finish
	if self:IsTargetInProximity (self.nProximityCheckID) then
		self:Finish ()
	end	
end

function WaitForProximity:OnEvent (tEvent)

	-- Target is now in proximity
	if tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self:Finish ()
		return true

	-- Target was deleted!
	elseif tEvent:HasID (self.nTargetDeletedID) then

		self:Finish ()
		return true

	end
	
	-- Call parent
	return Idle.OnEvent (self, tEvent)
end
