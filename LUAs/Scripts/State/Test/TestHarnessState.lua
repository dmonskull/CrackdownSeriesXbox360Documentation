----------------------------------------------------------------------
-- Name: TestHarnessState State
-- Description: Base state for all of the ai player tests
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

TestHarnessState = Create (State,
{
	sStateName = "TestHarnessState",

	bAllowBreakout = false,		-- If true then the user can break out of the test

	bTimeLimitActive = false,	-- If true then the test automatically times out
	nTimeLimit = 0,				-- Length of the timeout

	bInvinciblePlayer = true,	-- If true then the player is made invincible for the duration of the test
	bInfiniteAmmo = true,		-- If true then the player is given infinite ammo for the duration of the test

	bOutputLogOnExit = true,	-- If true then all messages logged during the test are output again when the test ends

	bEnableTargeting = false,	-- If true then OnTargetUpdate() is regularly called with a number of available targets
	nTargetUpdateRate = 5,		-- The number of seconds between calls to OnTargetUpdate()
	nTargetRange = 30,			-- Maximum distance that targets are scanned at

	bCheckForStuckness = false,	-- If true then the test checks to see if the player becomes stuck
	nStuckTableSize = 10,		-- A record of the last nStuckTableSize positions is recorded..
	nStuckTimerSpeed = 6,		-- ..every nStuckTimerSpeed seconds and the player must move..
	nStuckTolerance = 10,		-- ..at least nStuckTolerance far within that time or they are considered to be stuck
})


function TestHarnessState:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Initialise internal data
	self.bTestFinished = false
	self.bLoggingEnabled = true
	self.atTestMessageLog = {}
	self.nTestStartTimestamp = AILib.RetGameTimeSecs_DebugUseOnly ()

	-- Write a header
	self:TestStatusMessageNonLogging ("---------------------------------------- Test begun")

	-- Get a pointer to the player and set him up for ai control
	self.tPlayer = cPlayer:RetLocalPlayer ()
	assert (self.tPlayer)
	assert (self.tPlayer:IsA (cPlayer))
	self.bPreviousAIActive = self.tPlayer:IsAIActive ()
	self.tPlayer:SetAIActive (true)
	self.bPreviousAutomaticAIBreakout = self.tPlayer:IsAutomaticAIBreakout ()
	self.tPlayer:SetAutomaticAIBreakout (false)
	self.nAiBreakoutAttempt = self:Subscribe (eEventType.AIE_PLAYER_AI_BREAKOUT_ATTEMPT, self.tHost)

	-- Apply cheat settings
	local tCharacter = self.tPlayer:RetCharacter ()
	assert (tCharacter)
	assert (tCharacter:IsA (cCharacter))
	self.bPreviousInvinciblePlayer = tCharacter:IsInGodMode ()
	tCharacter:SetGodMode (self.bInvinciblePlayer)
	self.bPreviousInfiniteAmmo = tCharacter:IsInfiniteAmmo ()
	tCharacter:SetInfiniteAmmo (self.bInfiniteAmmo)
	
	-- Apply timelimit if specified
	if self.bTimeLimitActive then
		self:TestStatusMessage ("Starting timer of " .. tostring (self.nTimeLimit) .. " seconds ( game time )")
		self.nTestTimerID = self:AddTimer (self.nTimeLimit, false)
		self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	end
	
	-- Targeting
	if self.bEnableTargeting then
		self.bPreviousAiTargeting = self.tPlayer:IsAITargeting ()
		self.tPlayer:SetAITargeting (true)

		-- Add a repeating timer. We use use to search for props
		self.nTargetTimerID = self:AddTimer (self.nTargetUpdateRate, true)
		if not self.nTimerFinishedID then
			self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
		end
	end
	
	-- Initialise tests for player getting stuck
	if self.bCheckForStuckness then
		self.nStuckTimerID = self:AddTimer (self.nStuckTimerSpeed, true)
		self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
		self.avPlayerPositions = {}
	end

	self:OnResume ()
end


function TestHarnessState:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Go into Idle brain state
	self.tHost:Idle ()
end


function TestHarnessState:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	State.OnPause (self)
end


function TestHarnessState:OnExit ()
	self:OnPause ()

	-- Display the status
	self:TestStatusMessageNonLogging ("---------------------------------------- Test ended")
	local nTestLength = AILib.RetGameTimeSecs_DebugUseOnly () - self.nTestStartTimestamp
	self:TestStatusMessageNonLogging ("Took " .. tostring (nTestLength) .. " seconds ( real time )")
	if self.bTestFinished == true then
		assert (self.bTestPassed ~= nil)
		if self.bTestPassed then
			self:TestStatusMessageNonLogging ("Test Passed")
		else
			self:TestStatusMessageNonLogging ("Test Failed ( " .. self.sFailureReason .. " )")
		end
	else
		self:TestStatusMessageNonLogging ("Test did not finish normally!")
	end
	self.bLoggingEnabled = false
	self:OnOutputResults ()
	self.bLoggingEnabled = true

	-- Repeat all logged messages
	if self.bOutputLogOnExit then
		self:TestStatusMessageNonLogging ("---------------------------------------- Message log follows")
		for nIndex = 1, table.getn (self.atTestMessageLog) do
			self:_TestStatusMessage (self.atTestMessageLog[nIndex].sMessage, self.atTestMessageLog[nIndex].nTimestamp)
		end
	end
	self:TestStatusMessageNonLogging ("----------------------------------------")

	-- Return player to previous control type
	self.tPlayer:SetAIActive (self.bPreviousAIActive)
	self.tPlayer:SetAutomaticAIBreakout (self.bPreviousAutomaticAIBreakout)

	-- Restore cheat settings
	local tCharacter = self.tPlayer:RetCharacter ()
	assert (tCharacter)
	assert (tCharacter:IsA (cCharacter))
	tCharacter:SetGodMode (self.bPreviousInvinciblePlayer)
	tCharacter:SetInfiniteAmmo (self.bPreviousInfiniteAmmo)

	-- Restore targeting
	if self.bEnableTargeting then
		self.tPlayer:SetAITargeting (self.bPreviousAiTargeting)
	end

	-- Call parent
	State.OnExit (self)
end


function TestHarnessState:OnEvent (tEvent)
	if tEvent:HasID (self.nAiBreakoutAttempt) then
		if self.bAllowBreakout then
			self:TestStatusMessage ("User aborted test")
			self:Finish ()
		end
		return true
	end

	if self.nTestTimerID and self.nTimerFinishedID then
		if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTestTimerID) then
			self:TestStatusMessage ("Timer expired after " .. tostring (self.nTimeLimit) .. " seconds ( game time )")
			self:OnTimerFinished ()
			return true
		end
	end

	if self.bEnableTargeting then
		if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTargetTimerID) then
			self:OnTargetTimerFinished ()
			return true
		end
	end

	if self.bCheckForStuckness then
		if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nStuckTimerID) then
			self:OnStuckTimer ()
			return true
		end
	end
		
	-- Call parent
	return State.OnEvent (self, tEvent)
end


function TestHarnessState:TestStatusMessageNonLogging (sMessage)
	local nTimestamp = AILib.RetGameTimeSecs_DebugUseOnly ()
	self:_TestStatusMessage (sMessage, nTimestamp)
end


function TestHarnessState:_TestStatusMessage (sMessage, nTimeStamp)
	local sFormattedMessage = string.format ("[TEST:%s:%.2f] %s", self.sStateName, nTimeStamp, sMessage)
	AILib.Emit (sFormattedMessage)
end


function TestHarnessState:TestStatusMessage (sMessage)
	local nTimestamp = AILib.RetGameTimeSecs_DebugUseOnly ()
	self:_TestStatusMessage (sMessage, nTimestamp)
	if self.bLoggingEnabled then
		local nIndex = table.getn (self.atTestMessageLog)
		self.atTestMessageLog[nIndex + 1] = {}
		self.atTestMessageLog[nIndex + 1].sMessage = sMessage
		self.atTestMessageLog[nIndex + 1].nTimestamp = nTimestamp
	end
end


function TestHarnessState:TestPassed ()
	self.bTestPassed = true
	self.bTestFinished = true
	self:Finish ()
end


function TestHarnessState:TestFailed (sFailureReason)
	self.bTestPassed = false
	self.bTestFinished = true
	self.sFailureReason = sFailureReason
	self:Finish ()
end


function TestHarnessState:OnTargetTimerFinished ()
	local nTargets = self.tHost:GatherNearestObjects (self.nTargetRange, 20)
	self:OnTargetUpdate (nTargets)
end


function TestHarnessState:RetTarget (nTarget)
	local tTarget = self.tHost:RetGatheredNearestObject (nTarget)
	assert (tTarget)
	return tTarget
end


-- This function is triggered by a repeating timer event. We use it to test if the 
-- player has got stuck
function TestHarnessState:OnStuckTimer ()
	-- Check to see if the player has moved
	-- We need to have already collected enough samples before we can do this
	local vCurrentPosition = self.tPlayer:RetPosition ()
	if table.getn (self.avPlayerPositions) == self.nStuckTableSize then
		local bNotMoved = true
		for nIndex = 1, self.nStuckTableSize do
			local vRememberedPos = self.avPlayerPositions[nIndex]
			local vDifference= VecSubtract (vCurrentPosition, vRememberedPos)
			local nSquaredDistance = vDifference.x * vDifference.x +
									 vDifference.y * vDifference.y +
									 vDifference.z * vDifference.z
			if nSquaredDistance > self.nStuckTolerance * self.nStuckTolerance then
				bNotMoved = false
				break
			end
		end
		if bNotMoved then
			self:TestFailed ("Player became stuck! Failed to move more than " .. tostring (self.nStuckTolerance) .. " metres in " .. tostring (self.nStuckTableSize * self.nStuckTimerSpeed) .. " seconds" )
		end
	end

	-- Limit the size of the table
	if table.getn (self.avPlayerPositions) == self.nStuckTableSize then
		for nIndex = 1, self.nStuckTableSize do
			self.avPlayerPositions[nIndex] = self.avPlayerPositions[nIndex + 1]
		end
		assert (table.getn (self.avPlayerPositions) == self.nStuckTableSize - 1)
	else
		assert (table.getn (self.avPlayerPositions) < self.nStuckTableSize)
	end

	-- Add current position to end of the list
	self.avPlayerPositions[table.getn (self.avPlayerPositions) + 1] = vCurrentPosition 
end


-- Hook this to react to the target update
function TestHarnessState:OnTargetUpdate (nTargets)
end


-- Hook this to change the response to the timer running out
function TestHarnessState:OnTimerFinished ()
	self:TestPassed ()
end


-- Hook this to output customised test restults when the test ends
function TestHarnessState:OnOutputResults ()
end

