----------------------------------------------------------------------
-- Name: Timers
--	Description: Extends the State class - allows a state to set up timers
-- and records all timers it set up in a table so they can be
-- deleted automatically, thus avoiding memory leaks
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:AddTimer (nPeriod, bLooping)
	if not self.aTimerIDs then
		-- Make sure we are subscribed to the timer finished
		-- event, so that we can track timers
		self.nStateTimerFinished = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
		self.aTimerIDs = {}
		self.aNonLoopingTimerIDs = {}
	end

	local tAiTimerManager = cAiTimerManager.RetAiTimerManager ()
	assert (tAiTimerManager)

	local nTimerID = tAiTimerManager:AddTimer(self.tHost, nPeriod, bLooping)
	
	if bLooping == true then
		self.aTimerIDs[nTimerID] = nTimerID
	else
		self.aNonLoopingTimerIDs[nTimerID] = nTimerID
	end
	return nTimerID
end

function State:DeleteTimer (nTimerID)
	assert(self.aTimerIDs)
	local tAiTimerManager = cAiTimerManager.RetAiTimerManager ()
	assert (tAiTimerManager)

	--assert(self.aTimerIDs[nTimerID] == nTimerID)
	tAiTimerManager:DeleteTimer (nTimerID)
	if self.aTimerIDs[nTimerID] ~= nil then
		self.aTimerIDs[nTimerID] = nil
	elseif self.aNonLoopingTimerIDs[nTimerID] ~= nil then
		self.aNonLoopingTimerIDs[nTimerID] = nil
	end
end

function State:PauseTimer (nTimerID)
	assert(self.aTimerIDs)
	local tAiTimerManager = cAiTimerManager.RetAiTimerManager ()
	assert (tAiTimerManager)

	--assert(self.aTimerIDs[nTimerID] == nTimerID)
	tAiTimerManager:PauseTimer (nTimerID)
end

function State:ResumeTimer (nTimerID)
	assert(self.aTimerIDs)
	local tAiTimerManager = cAiTimerManager.RetAiTimerManager ()
	assert (tAiTimerManager)

	--assert(self.aTimerIDs[nTimerID] == nTimerID)
	tAiTimerManager:ResumeTimer (nTimerID)
end

function State:DeleteAllTimers()
	if self.aTimerIDs then
		for nTimerID in pairs(self.aTimerIDs) do
			self:DeleteTimer( nTimerID )
		end
	end

	if self.aNonLoopingTimerIDs then
		for nTimerID in pairs(self.aNonLoopingTimerIDs) do
			self:DeleteTimer( nTimerID )
		end
	end
end

function State:PauseAllTimers()
	if self.aTimerIDs then
		for nTimerID in pairs(self.aTimerIDs) do
			self:PauseTimer( nTimerID )
		end
	end

	if self.aNonLoopingTimerIDs then
		for nTimerID in pairs(self.aNonLoopingTimerIDs) do
			self:PauseTimer( nTimerID )
		end
	end
end

function State:ResumeAllTimers()
	if self.aTimerIDs then
		for nTimerID in pairs(self.aTimerIDs) do
			self:ResumeTimer( nTimerID )
		end
	end

	if self.aNonLoopingTimerIDs then
		for nTimerID in pairs(self.aNonLoopingTimerIDs) do
			self:ResumeTimer( nTimerID )
		end
	end
end
