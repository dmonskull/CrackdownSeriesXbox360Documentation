----------------------------------------------------------------------
-- Name: TimedDodge State
--	Description: As with dodge but expires after a certain amount of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Dodge\\Dodge"

TimedDodge = Create (Dodge, 
{
	sStateName = "TimedDodge",
	nTimeout = 1,
})

function TimedDodge:OnEnter ()
	-- Call parent
	Dodge.OnEnter (self)

	-- Check parameters
	assert (self.nTimeout)

	if self.nTimeout > 0 then
		-- Start non-looping timer
		self.nTimerID = self:AddTimer (self.nTimeout, false)
	else
		self:Finish ()
	end

	-- Subscribe to events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function TimedDodge:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return Dodge.OnEvent (self, tEvent)
end
