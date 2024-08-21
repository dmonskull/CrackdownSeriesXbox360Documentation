----------------------------------------------------------------------
-- Name: WaitForProximityAndFace State
--	Description: Stand and face the target until it comes within a specified
-- distance of me
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Turn\\Face"

WaitForProximityAndFace = Create (Face, 
{
	sStateName = "WaitForProximityAndFace",
	nRadius = 3,
})

function WaitForProximityAndFace:OnEnter ()
	-- Subscribe to events
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)

	-- Call parent
	Face.OnEnter (self)
end

function WaitForProximityAndFace:OnResume ()
	-- Call parent
	Face.OnResume (self)

	-- Set up proximity check
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nRadius)

	-- Target is already in proximity so just finish
	if self:IsTargetInProximity (self.nProximityCheckID) then
		self:Finish ()
	end	
end

function WaitForProximityAndFace:OnPause ()
	-- Delete proximity check
	self:DeleteProximityCheck (self.nProximityCheckID)

	-- Call parent
	Face.OnPause (self)
end

function WaitForProximityAndFace:OnEvent (tEvent)

	-- Target is now in proximity
	if tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self:Finish ()
		return true

	end
	
	-- Call parent
	return Face.OnEvent (self, tEvent)
end
