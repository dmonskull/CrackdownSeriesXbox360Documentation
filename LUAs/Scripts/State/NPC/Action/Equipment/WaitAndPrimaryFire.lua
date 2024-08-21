----------------------------------------------------------------------
-- Name: WaitAndPrimaryFire State
--	Description: Shoot the target for a specified period of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Equipment\\FaceAndPrimaryFire"

WaitAndPrimaryFire = Create (FaceAndPrimaryFire, 
{
	sStateName = "WaitAndPrimaryFire",
})

function WaitAndPrimaryFire:OnEnter ()
	-- Call parent
	FaceAndPrimaryFire.OnEnter (self)

	-- Check parameters
	assert (self.nWaitTime)

	if self.nWaitTime > 0 then
		-- Start non-looping timer
		self.nTimerID = self:AddTimer (self.nWaitTime, false)
	else
		self:Finish ()
	end

	-- Subscribe to timer finished event
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function WaitAndPrimaryFire:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return FaceAndPrimaryFire.OnEvent (self, tEvent)
end
