----------------------------------------------------------------------
-- Name: TimedRetreat State
--	Description: Stops retreating if no damage has been taken within specified time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Retreat\\Retreat"

TimedRetreat = Create (Retreat, 
{
	sStateName = "TimedRetreat",
	nTimeout = 20,
})

function TimedRetreat:OnEnter ()
	-- Call parent
	Retreat.OnEnter (self)

	-- Check parameters
	assert (self.nTimeout)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	self:ResetTimer ()
end

function TimedRetreat:ResetTimer ()
	if self.nTimerID then
		self:DeleteTimer (self.nTimerID)
	end
	self.nTimerID = self:AddTimer (self.nTimeout, false)
end

function TimedRetreat:OnEvent (tEvent)

	if tEvent:HasID (self.nDamagedID) then
	
		-- Restart timer
		self:ResetTimer ()

		-- Call parent
		return Retreat.OnEvent (self, tEvent)

	elseif tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return Retreat.OnEvent (self, tEvent)
end

