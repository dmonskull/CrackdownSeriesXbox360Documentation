----------------------------------------------------------------------
-- Name: Time Of Day
--	Description: Extends the State class - allows a state to set up time of
-- day events, and records all ToD events it sets up in a table so they can be
-- deleted automatically, thus avoiding memory leaks
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:RequestTimeOfDayNotification(nTime, bRepeat)
	assert(nTime)
	assert(bRepeat ~= nil)

	if not self.aTodIDs then
		self.aTodIDs = {}
	end
	
	local TOD = cTimeOfDay.RetTimeOfDayManager()
	assert(TOD)
	local TodID = TOD:AddTimeOfDayEvent(self.tHost, nTime, bRepeat)

	self.aTodIDs[TodID] = TodID

	return TodID
end

function State:StopTimeOfDayNotification(nTodID)
	assert(nTodID)
	assert(self.aTodIDs)

	local TOD = cTimeOfDay.RetTimeOfDayManager()
	assert(TOD)
	
	assert(self.aTodIDs[nTodID] == nTodID)
	TOD:RemoveTimeOfDayEvent(nTodID)
	self.aTodIDs[nTodID] = nil
end

function State:StopAllTimeOfDayNotifications()
	if self.aTodIDs then
		for nTodID in pairs(self.aTodIDs) do
			self:StopTimeOfDayNotification(nTodID)
		end
	end
end

function State:RetTimeOfDayNotification(nTodID)
	assert(nTodID)
	local TOD = cTimeOfDay.RetTimeOfDayManager()
	assert(TOD)
	return TOD:RetTimeOfDayEvent(nTodID)
end

