_LOADED = {}		-- empties the list of loaded files.

require "State\\NPC\\Action\\Vehicles\\Driveto"
require "Debug\\Sams\\Sam_Common"

--- About this race -----------------------------------------------------------------------------------------------------

-- Racing To Funland
vTarget = MakeVec3 (1052, 20, -817)

-- player character will go to this position
local tPlayer = cAiManager.RetAiManager ():RetPlayer (0)
tPlayer:ForcePos(963, 48, -1576)


--- Setup Racing Vehicles -----------------------------------------------------------------------------------------------------

-- Number of vehicles in this race
NumVehicles = 9

-- Where do we want these vehicle spawned
vSpawnPosition = {}
for j = 1, 6 do
	vSpawnPosition[j] = MakeVec3(973, 47, -1578);
end

for j = 7, NumVehicles do
	vSpawnPosition[j] = MakeVec3(989, 46, -1567);
end


local nCarToUse = {6, 6, 6, 6, 6, 6, 6, 6, 6}
local LaneLayout =  { {0,0}, {1, 0}, {2,0}, {0, 1}, {1, 1}, {2,1} ,{0,0}, {1, 0}, {2,0} }

for j = 1, NumVehicles do
	local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( 
	tSamsVehicles[nCarToUse[j]], 
	"Config\\NPC\\Sam3", 
	vSpawnPosition[j], 
	LaneLayout[j][1], LaneLayout[j][2])
	tDrivers[  j ] = tVehicle:RetPtrDriver ()
end
----------------------------------------------------------------------------------------------------------------

MidTownRace = Create (State,
{
	sStateName = "MidTownRace",
})

function MidTownRace:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	self.nTimerID = self:AddTimer (10, false) -- 10 second non-looping timer
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function MidTownRace:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		Emit ("Starting Midtown Race...")

		for j = 1, NumVehicles do
			if tDrivers[j]:IsInVehicle() then
				tDrivers[j]:SetState( Create(Driveto, 
				{
				--tTarget = tPlayer,			-- vTargetPosition = vPlayerPos, for a direct position
				 vTargetPosition = vTarget,
				 nSpeed =100,
				bFullPhysics = true,
				bSlowDownAvoidance =false,
				bMatchSpeed = true,
				bCompeteForOneLane = true, 
				bSenseOnGrid = true
				}))
			end
		end
		
		Emit ("Finished Midtown Race...")
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

if not tMidTownRaceMission then
	tMidTownRaceMission = MissionManager.NewMission ("MidTownRace", nil, "")
end
tMidTownRaceMission:SetState (MidTownRace)