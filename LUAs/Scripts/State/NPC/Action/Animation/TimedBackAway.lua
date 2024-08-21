----------------------------------------------------------------------
-- Name: TimedBackAway State
--	Description: Back away for a specified period of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\BackAway"

TimedBackAway = Create (BackAway, 
{
	sStateName = "TimedBackAway",
})

function TimedBackAway:OnEnter ()
	-- Call parent
	BackAway.OnEnter (self)

	-- Check parameters
	assert (self.nTimeout)

	if self.nTimeout > 0 then
		-- Start non-looping timer
		self.nTimerID = self:AddTimer (self.nTimeout, false)
	else
		self:Finish ()
	end

	-- Subscribe to timer finished event
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function TimedBackAway:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return BackAway.OnEvent (self, tEvent)
end
