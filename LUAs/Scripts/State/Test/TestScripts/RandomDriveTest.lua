----------------------------------------------------------------------
-- Name: RandomDriveTest State
-- Description: Test script to make the player attempt to drive to randomly 
-- selected points in the game world
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Test\\TestHarnessState"
require "State\\NPC\\Action\\Vehicles\\MoveToAndEnterVehicle"
require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Action\\Idle\\Wait"
require "State\\Test\\TestScripts\\RandomDrivePoints"
require "State\\NPC\\Action\\Vehicles\\Driveto"


RandomDriveTest = Create (TestHarnessState,
{
	sStateName = "RandomDriveTest",

	bTimeLimitActive = true,			-- Test passes if the player manages to drive without getting..
	nTimeLimit = 60*10,					-- ..stuck for this amount of time
	bEnableTargeting = true,			-- We need AI targeting

	sVehicleAssetName = "CIV_004_Cabriolet",	-- Vehicle to use
	
	nPositionTolerance = 10,			-- Player must be within this many meers of the marker position when he arrives

	bCheckForStuckness = true,			-- If true then the test checks to see if the player becomes stuck
	nStuckTableSize = 10,				-- A record of the last nStuckTableSize positions is recorded..
	nStuckTimerSpeed = 6,				-- ..every nStuckTimerSpeed seconds and the player must move..
	nStuckTolerance = 20,				-- ..at least nStuckTolerance far within that time or they are considered to be stuck
})


function RandomDriveTest:OnEnter ()
	-- Call parent
	TestHarnessState.OnEnter (self)


	-- Spawn the test vehicle
	self:TestStatusMessage ("Spawning vehicle '" .. self.sVehicleAssetName .. "'")
	self.tVehicle = SpawnInFrontOfPlayer (self.sVehicleAssetName, 10)
	assert (self.tVehicle)
	
	-- Wait a second to allow the car to settle
	self:PushState (Create (Wait,
	{
		nWaitTime = 1,
	}))

	-- Initialise internal data
	self.nPointsChosen = 0
	self.nPointsReached = 0
	self.atTargetPointRecords = {}

end


function RandomDriveTest:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (Wait) then

		-- Finished waiting, now try and enter the vehicle	
		self:TestStatusMessage ("Getting player into vehicle")
		self:ChangeState (Create (MoveToAndEnterVehicle,
		{
			tTarget = self.tVehicle,
			nSelectedDoor = 1,
		}))
		return true
		
	elseif tState:IsA (MoveToAndEnterVehicle) then

		-- Finished trying to enter the vehicle
		if tState:Success () then
			self:TestStatusMessage ("Entered vehicle successfully")
			self:PopState ()
			self:MoveToPoint (self:SelectRandomPoint ())
		else
			self:TestFailed ("Failed to enter vehicle successfully")
		end
		return true
		
	elseif self:IsInState (Driveto) then
		local nCurrentTiemstamp = AILib.RetGameTimeSecs_DebugUseOnly ()
		
		-- Did we manage to reach the point?
		local tState = self:RetActiveState ()
		if tState:Success () then
		
			-- Yes, check that we actually reached it
			local vTargetPosition = avRandomDrivePoints[self.nLastSelectedPoint]
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


function RandomDriveTest:SelectRandomPoint ()
	-- Choose a random point but not the same as last time
	local nAvailablePoints = table.getn (avRandomDrivePoints)
	assert (nAvailablePoints > 1)
	local nSelectedPoint
	repeat
		nSelectedPoint = cAIPlayer.Rand (1, nAvailablePoints)
	until nSelectedPoint ~= self.nLastSelectedPoint
	
	-- Remember the last point chosen
	self.nLastSelectedPoint = nSelectedPoint

	-- Output some status info
	local vDestination = avRandomDrivePoints[nSelectedPoint]
	local sLocationString = tostring (vDestination.x) .. "," .. tostring (vDestination.y) .. "," .. tostring (vDestination.z)
	self:TestStatusMessage ("Driving to point " .. tostring (nSelectedPoint) .. "/" .. tostring (nAvailablePoints) .. " @ " .. sLocationString)

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


function RandomDriveTest:MoveToPoint (nPointNumber)
	local vDestination = avRandomDrivePoints[nPointNumber]
	self:PushState (Create (Driveto,
	{
		vTargetPosition = vDestination,
		nSpeed = 50,
		bFullPhysics = true,
		bSlowDownAvoidance =false,
		bMatchSpeed = true,
		bCompeteForOneLane = true, 
		bSenseOnGrid = true,
	}))
end


function RandomDriveTest:OnOutputResults ()
	self:TestStatusMessage ("Tried to drive to " .. tostring (self.nPointsChosen) .. " points")
	self:TestStatusMessage ("Managed to reach " .. tostring (self.nPointsReached) .. " of those")
	for nIndex = 1, table.getn (avRandomDrivePoints) do
		if self.atTargetPointRecords[nIndex] then
			self:TestStatusMessage ("Point " .. tostring (nIndex ) ..
									": Attempts " .. tostring (self.atTargetPointRecords[nIndex].nAttempts) ..
									", Successes " .. tostring (self.atTargetPointRecords[nIndex].nSuccesses) ..
									", Failures " .. tostring (self.atTargetPointRecords[nIndex].nFailures))
		end
	end
end