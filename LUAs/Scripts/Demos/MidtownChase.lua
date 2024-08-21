_LOADED = {}		-- empties the list of loaded files.

require "State\\NPC\\Action\\Vehicles\\Chase"
require "State\\NPC\\Action\\Vehicles\\Driveto"
require "Debug\\Sams\\Sam_Common"


-- chase position
--vTarget = MakeVec3 (984, 47, -1568)		-- Quite near to spawn position
vTarget = MakeVec3 (1052, 20, -817)


-- player character will go to this position
local tPlayer = cAiManager.RetAiManager ():RetPlayer (0)
tPlayer:ForcePos(1008, 48, -1565)


-- Spawn Chase and Flee Vehicles -------------------------------------------------------------------------------------------------------------
NumVehicles = 1

local nCommonCar = {6, 6, 6, 6, 6, 6}

-- Where do we want the chase vehicle spawned
local vSpawnPosition = MakeVec3(973, 47, -1578)

local tVehicleChase = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( 
tSamsVehicles[nCommonCar[1]], 
"Config\\NPC\\Sam3", 
vSpawnPosition,
 0, 0)
tChaser = tVehicleChase:RetPtrDriver ()

-- The flee vehicle spawn position
local vSpawnPosition = MakeVec3(1004, 46, -1561)

local tVehicleFlee = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( 
tSamsVehicles[nCommonCar[2]], 
"Config\\NPC\\Sam3", 
vSpawnPosition,
 0, 0)
tFleer = tVehicleFlee:RetPtrDriver ()


----------------------------------------------------------------------------------------------------------------
MidTownChase = Create (State,
{
	sStateName = "MidtownChase",
})

function MidTownChase:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	self.nTimerID = self:AddTimer (8, false) -- 10 second non-looping timer
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function MidTownChase:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		Emit ("Starting MidtownChase...")
		
			-- Who flees, agent or player, Chaser after vehicle no matter who is in it.
			if tFleer:IsInVehicle() then
				tFleer:SetState( Create(Driveto, 
				{
				vTargetPosition = vTarget,
				nSpeed = 10,
				bFullPhysics = true,
				bSlowDownAvoidance = true,
				bMatchSpeed = true,
				bCompeteForOneLane = false, 
				bSenseOnGrid = false
				}))

				tFleerTarget = tFleer
			end

			-- The chasing vehicle
			if tChaser:IsInVehicle() then

				Emit (" Midtownchase Has vehicle")

				tChaser:SetState( Create(VChase, 
				{
				tTarget = self.tVehicleFlee,			-- yes, we are chasing the fleer
				nSpeed =150,
				bFullPhysics = false,
				bSlowDownAvoidance = false,
				bMatchSpeed = true,
				bCompeteForOneLane = false, 
				bSenseOnGrid = true,
				nStopRadius = 8						-- this should not be too small or too large, even though we adjust for minimum braking distance to stop in time inside
				}))
			else
		
				Emit (" Midtownchase No vehicle")

			end
		
		
		Emit ("Finished MidtownChase...")
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

if not tMidTownChaseMission then
	Emit ("Create a MidtownChase mission")
	tMidTownChaseMission = MissionManager.NewMission ("MidtownChase", nil, "")
end
tMidTownChaseMission:SetState (Create (MidTownChase,
{
	tVehicleFlee = tVehicleFlee,
}))