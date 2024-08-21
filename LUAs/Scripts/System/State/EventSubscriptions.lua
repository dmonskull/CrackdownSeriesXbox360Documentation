----------------------------------------------------------------------
-- Name: Event Subscriptions
--	Description: Extends the State class - allows a state to subscribe to
-- events, and records all subscribed events in a table so they can be
-- unsubscribed from automatically, thus avoiding memory leaks
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:Subscribe (nEventIndex, tSourceFilter)
	assert (self.tHost)
	assert (type (nEventIndex) == "number")

	if not self.asSubscribedEvent then
		self.asSubscribedEvent = {}
	end

	-- Call host to subscribe
	local nEventID = self.tHost:Subscribe (nEventIndex, tSourceFilter)

	-- Record registered event names
	self.asSubscribedEvent[nEventID] = nEventIndex

	return nEventID
end

function State:SubscribeImmediate (nEventIndex, tSourceFilter)
	assert (self.tHost)
	assert (type (nEventIndex) == "number")

	if not self.asSubscribedEvent then
		self.asSubscribedEvent = {}
	end

	-- Call host to subscribe
	local nEventID = self.tHost:SubscribeImmediate (nEventIndex, tSourceFilter)

	-- Record registered event names
	self.asSubscribedEvent[nEventID] = nEventIndex

	return nEventID
end

function State:Unsubscribe (nEventID)
	assert (self.tHost)
	assert (self.asSubscribedEvent)
	assert (self.asSubscribedEvent[nEventID])

	-- Call host to unsubscribe
	self.tHost:Unsubscribe (nEventID, self.asSubscribedEvent[nEventID])

	-- remove event name from list
	self.asSubscribedEvent[nEventID] = nil
end

function State:UnsubscribeAll ()
	if self.asSubscribedEvent then
		for nEventID, nEventIndex in pairs (self.asSubscribedEvent) do
			self.tHost:Unsubscribe (nEventID, nEventIndex)
		end
		self.asSubscribedEvent = nil
	end
end
