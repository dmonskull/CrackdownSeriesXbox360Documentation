----------------------------------------------------------------------
-- Name: Wait State
--	Description: Stand idle for a specified period of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Idle\\Idle"

Wait = Create (Idle, 
{
	sStateName = "Wait",
})

function Wait:OnEnter ()
	-- Call parent
	Idle.OnEnter (self)

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

function Wait:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return Idle.OnEvent (self, tEvent)
end
