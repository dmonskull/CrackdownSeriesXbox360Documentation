require "State\\NPC\\Action\\Idle\\Idle"
require "State\\NPC\\Action\\Vehicles\\Driveto"
require "Debug\\Sams\\Sam_Common"

Emit ("Starting Sam1...")

-- Where do we want this vehicle spawned
local vSpawnPosition = MakeVec3(1020, 21,, -2420)

NumVehicles = 1;
local iLane = 2
local tVehicle = cAiManager.RetAiManager():SpawnAiVehicleAtPosition( tSamsVehicles[6] , "Config\\NPC\\Sam3", 
vSpawnPosition,
 iLane, 0)
tDrivers[1] = tVehicle:RetPtrDriver ()

-- The speed for driving
fDriveSpeed =20;

-- Racing To Junction in North Island
vTarget = MakeVec3 (902.1, 4.85, -2744.7)


Emit ("Finished Sam1...")
