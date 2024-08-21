---------------------------------------------------------------------
-- Name: MasterTalk State
-- Description: Say something, wait a while, then finish
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
---------------------------------------------------------------------

require "System\\State"

MasterTalk = Create (State, 
{
	sStateName = "MasterTalk",
})

function MasterTalk:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Call the member function SaySomething
	self:SaySomething ()

	-- Add a non-looping timer for four seconds
	self.nTimerID = self:AddTimer (4, false)

	-- Subscribe to timer finished event
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function MasterTalk:SaySomething ()
	-- Say something
	self.tHost:Speak ("wibble")
end

function MasterTalk:OnEvent (tEvent)

	-- Trap the Timer Finished event
	if tEvent:HasID (self.nTimerFinishedID) and

		-- Check that it is our timer that finished
		tEvent:HasTimerID (self.nTimerID) then

		-- This function finishes the state, which calls the
		-- OnActiveStateFinished function of the state which
		-- pushed this state onto its stack
		self:Finish ()
		return true

	end

	-- If no event is trapped then just call parent
	return State.OnEvent (self, tEvent)
end
