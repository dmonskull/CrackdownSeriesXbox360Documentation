----------------------------------------------------------------------
-- Name: RandomWalkTest State
-- Description: Test script to make the player attempt to walk to randomly 
-- selected points in the game world
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Movement\\Move"
require "State\\Test\\TestHarnessState"
require "State\\Test\\TestScripts\\RandomWalkPoints"

RandomWalkTest = Create (TestHarnessState,
{
	sStateName = "RandomWalkTest",

	bTimeLimitActive = true,			-- Test passes if the player manages to walk without getting..
	nTimeLimit = 60*10,					-- ..stuck for this amount of time

	nMovementType = eMovementType.nRun,	-- We actually default to run, otherwise the test is very slow
	nPositionTolerance = 2,				-- Player must be within this many meers of the marker position when he arrives
	bCheckForStuckness = true,			-- If true then the test checks to see if the player becomes stuck
	nStuckTableSize = 10,				-- A record of the last nStuckTableSize positions is recorded..
	nStuckTimerSpeed = 2,				-- ..every nStuckTimerSpeed seconds and the player must move..
	nStuckTolerance = 5,				-- ..at least nStuckTolerance far within that time or they are considered to be stuck
})


function RandomWalkTest:OnEnter ()
	-- Call parent
	TestHarnessState.OnEnter (self)

	-- Initialise internal data
	self.nPointsChosen = 0
	self.nPointsReached = 0
	self.atTargetPointRecords = {}

	-- Start with the walking already
	self:MoveToPoint (self:SelectRandomPoint ())
end


function RandomWalkTest:OnActiveStateFinished ()
	if self:IsInState (Move) then
		local nCurrentTiemstamp = AILib.RetGameTimeSecs_DebugUseOnly ()
		
		-- Did we manage to reach the point?
		local tState = self:RetActiveState ()
		if tState:Success () then
		
			-- Yes, check that we actually reached it
			local vTargetPosition = avRandomWalkPoints[self.nLastSelectedPoint]
			local vActualPosition = self.tPlayer:RetPosition ()
			local nError = VecDistance (vTargetPosition, vActualPosition)
			if nError <= self.nPositionTolerance then
				self:TestStatusMessage ("Reached point ( distance to target point is " .. tostring (nError) .. " )")
				self.atTargetPointRecords[self.nLastSelectedPoint].nSuccesses = self.atTargetPointRecords[self.nLastSelectedPoint].nSuccesses + 1
				self.nPointsReached = self.nPointsReached + 1
			else
				self:TestStatusMessage ("Reached point but was not within tolerance! ( distance to target point is " .. tostring (nError) .. " )")
				self.atTargetPointRecords[self.nLastSelectedPoint].nFailures = self.atTargetPointRecords[self.nLastSelectedPoint].nFailures + 1
			end
			
		else
		
			-- No
			self:TestStatusMessage ("Ai system says we failed to reach point!")
			self.atTargetPointRecords[self.nLastSelectedPoint].nFailures = self.atTargetPointRecords[self.nLastSelectedPoint].nFailures + 1
			
		end

		-- Go to another point
		self:PopState ()
		self:MoveToPoint (self:SelectRandomPoint ())

		return true
	end
		
	-- Call parent
	return TestHarnessState.OnActiveStateFinished (self)
end


function RandomWalkTest:SelectRandomPoint ()
	-- Choose a random point but not the same as last time
	local nAvailablePoints = table.getn (avRandomWalkPoints)
	assert (nAvailablePoints > 1)
	local nSelectedPoint
	repeat
		nSelectedPoint = cAIPlayer.Rand (1, nAvailablePoints)
	until nSelectedPoint ~= self.nLastSelectedPoint
	
	-- Remember the last point chosen
	self.nLastSelectedPoint = nSelectedPoint

	-- Output some status info
	local vDestination = avRandomWalkPoints[nSelectedPoint]
	local sLocationString = tostring (vDestination.x) .. "," .. tostring (vDestination.y) .. "," .. tostring (vDestination.z)
	self:TestStatusMessage ("Walking to point " .. tostring (nSelectedPoint) .. "/" .. tostring (nAvailablePoints) .. " @ " .. sLocationString)

	self.nPointsChosen = self.nPointsChosen + 1
	if self.atTargetPointRecords[nSelectedPoint] == nil then
		self.atTargetPointRecords[nSelectedPoint] = {}
		self.atTargetPointRecords[nSelectedPoint].nAttempts = 0
		self.atTargetPointRecords[nSelectedPoint].nSuccesses = 0
		self.atTargetPointRecords[nSelectedPoint].nFailures = 0
	end
	self.atTargetPointRecords[nSelectedPoint].nAttempts = self.atTargetPointRecords[nSelectedPoint].nAttempts + 1
	
	return nSelectedPoint
end


function RandomWalkTest:MoveToPoint (nPointNumber)
	local vDestination = avRandomWalkPoints[nPointNumber]
	self:PushState (Create (Move, {
		nMovementType = eMovementType.nRun,
		vDestination = MakeVec3 (vDestination.x, vDestination.y, vDestination.z),
	}))
end


function RandomWalkTest:OnOutputResults ()
	self:TestStatusMessage ("Tried to walk to " .. tostring (self.nPointsChosen) .. " points")
	self:TestStatusMessage ("Managed to reach " .. tostring (self.nPointsReached) .. " of those")
	for nIndex = 1, table.getn (avRandomWalkPoints) do
		if self.atTargetPointRecords[nIndex] then
			self:TestStatusMessage ("Point " .. tostring (nIndex ) ..
									": Attempts " .. tostring (self.atTargetPointRecords[nIndex].nAttempts) ..
									", Successes " .. tostring (self.atTargetPointRecords[nIndex].nSuccesses) ..
									", Failures " .. tostring (self.atTargetPointRecords[nIndex].nFailures))
		end
	end
end