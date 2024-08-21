require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Action\\Vehicles\\Driveto"
require "Debug\\Sams\\Sam_Common"

Emit ("Starting Sam2...")

-- Where do we want this vehicle spawned
local vSpawnPosition = MakeVec3(973, 47, -1578)

NumVehicles = 1;

local iLane = -1
local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[6] , "Config\\NPC\\Sam3",
vSpawnPosition,
iLane, 0)
tDrivers[1] = tVehicle:RetPtrDriver ()

--[[
local iLane = 1
local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[6] , "Config\\NPC\\Sam3", vSpawnPosition.x, 
vSpawnPosition,
  iLane, 0)
tDrivers[2] = tVehicle:RetPtrDriver ()
]]--

Emit ("Finished Sam2...")