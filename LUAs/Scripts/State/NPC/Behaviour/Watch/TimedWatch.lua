----------------------------------------------------------------------
-- Name: Watch State
--	Description: Stand around and watch some kind of fight
-- Cheer and boo at appropriate moments
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Watch\\Watch"

TimedWatch = Create (Watch, 
{
	sStateName = "TimedWatch",
	nTimeout = 10,
})

function TimedWatch:OnEnter ()
	-- Call parent
	Watch.OnEnter (self)

	self:ResetTimer ()
end

function TimedWatch:OnEvent (tEvent)

	if tEvent:HasID (self.nCorpseAppearedID) then

		self:ResetTimer ()
		return Watch.OnEvent (self, tEvent)

	elseif tEvent:HasID (self.nWeaponSoundID) then

		self:ResetTimer ()
		return Watch.OnEvent (self, tEvent)

	elseif tEvent:HasID (self.nDangerVocalID) then

		self:ResetTimer ()
		return Watch.OnEvent (self, tEvent)

	elseif tEvent:HasID (self.nPainVocalID) then

		self:ResetTimer ()
		return Watch.OnEvent (self, tEvent)

	elseif tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		-- Nothing has happened for a while - lose interest 
		self:Finish ()
		return true

	end

	-- Call parent
	return Watch.OnEvent (self, tEvent)
end

function TimedWatch:ResetTimer ()
	if self.nTimerID then
		self:DeleteTimer (self.nTimerID)
	end
	self.nTimerID = self:AddTimer (self.nTimeout, false)
end
