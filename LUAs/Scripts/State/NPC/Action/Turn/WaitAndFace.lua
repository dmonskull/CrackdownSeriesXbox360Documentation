----------------------------------------------------------------------
-- Name: WaitAndFace State
--	Description: Face the target for a specified period of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Turn\\Face"

WaitAndFace = Create (Face, 
{
	sStateName = "WaitAndFace",
})

function WaitAndFace:OnEnter ()
	-- Call parent
	Face.OnEnter (self)

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

function WaitAndFace:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return Face.OnEvent (self, tEvent)
end
