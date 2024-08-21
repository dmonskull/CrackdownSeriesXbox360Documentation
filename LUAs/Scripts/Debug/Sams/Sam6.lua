require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Action\\Vehicles\\Driveto"
require "Debug\\Sams\\Sam_Common"

Emit ("Starting Sam6...")

-- Where do we want this vehicle spawned
local vSpawnPosition = MakeVec3(973, 47, -1578)

NumVehicles = 6

local nCommonCar = {6, 6, 6, 6, 6, 6}

local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[nCommonCar[1]], "Config\\NPC\\Sam3",
vSpawnPosition,
 0, 0)
tDrivers[  1 ] = tVehicle:RetPtrDriver ()

local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[nCommonCar[2]], "Config\\NPC\\Sam3", 
vSpawnPosition,  
 1, 0)
tDrivers[  2 ] = tVehicle:RetPtrDriver ()

local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[nCommonCar[3]], "Config\\NPC\\Sam3", 
vSpawnPosition,
  0, 1)
tDrivers[  3 ] = tVehicle:RetPtrDriver ()

local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[nCommonCar[4]], "Config\\NPC\\Sam3", 
vSpawnPosition,
  1, 1)
tDrivers[  4 ] = tVehicle:RetPtrDriver ()

local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[nCommonCar[5]], "Config\\NPC\\Sam3",
vSpawnPosition,
  2, 0)
tDrivers[  5 ] = tVehicle:RetPtrDriver ()

local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[nCommonCar[6]], "Config\\NPC\\Sam3", 
vSpawnPosition, 
 2, 1)
tDrivers[  6 ] = tVehicle:RetPtrDriver ()


Emit ("Finished Sam6...")
