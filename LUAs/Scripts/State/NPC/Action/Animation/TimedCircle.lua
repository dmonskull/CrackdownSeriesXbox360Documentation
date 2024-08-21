----------------------------------------------------------------------
-- Name: TimedCircle State
-- Description: Circle for a specified period of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\Circle"

TimedCircle = Create (Circle, 
{
	sStateName = "TimedCircle",
})

function TimedCircle:OnEnter ()
	-- Call parent
	Circle.OnEnter (self)

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

function TimedCircle:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then
		
		self:Finish ()
		return true
		
	end
	
	-- Call parent
	return Circle.OnEvent (self, tEvent)
end
