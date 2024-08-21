
tSamsVehicles = {
"G3_074_SportsCar",
"G3_041_MuscleCar",
"CIV_011_Roadster",
"CIV_005_Sportscar01",
"G2_062_MobSaloon",
"G1_039_JapaneseCar"
}

local tAiManager = cAiManager.RetAiManager ()
tPlayer = tAiManager:RetPlayer (0)

-- The player position for dynamic targeting
--vTarget = MakeVec3 (tPlayer:RetPosition ())
 
-- This is the first location of travel the zebra crossing
--vTarget = MakeVec3 (1187,31,-1331)

-- The second one which brakes at the slip road
--local vTarget = MakeVec3 (1251,18,-953)

-- The one far away but promising
--local vTarget = MakeVec3 (1326,31,-1701)

-- The one that does not get to the top
--local vTarget = MakeVec3 (838,65,-1250)

-- The far away beach
--local vTarget = MakeVec3 (911, 5, -1835)
--local vTarget = MakeVec3 (675,  30, -1340)

-- Underpass just around the corner
--local vTarget = MakeVec3 (907,  43, -1483)

-- To Funland
vTarget = MakeVec3 (1052, 20, -817)

-- The underpass going into the incompleted channel tunnel
--vTarget = MakeVec3(1083, 43, -1653)


fDriveSpeed = 50
NumVehicles = 0
tDrivers = {}

------------------------------------------------------------------------------------------
--local tNPC = cAIPlayer.SpawnNPCAtNamedLocation ( "AIStreetSoldier1", "PedestrianStart" )
--local tNPC = cAIPlayer.SpawnNPC("AIStreetSoldier1", 1098, 31, -1031)

--tNPC:SetState (Create (Move, 
--{
	--vDestination = MakeVec3 (1047, 30.9, -1017), -- Down the pavement, same cell
	--vDestination = MakeVec3 (1053, 30.8, -986), -- Around the corner, different cell
	--vDestination = MakeVec3 (1135, 30, -889), -- Up the steps from the road
	--vDestination = MakeVec3 (1129.4, 27.7, -891), -- Half way up the steps from the road
--})) 

--  -- cAiPlayer.FRand(0,1)	-- in the range 0,1 

--tDriver:SetState( Idle )

function DoFunction (fMyFunction, tMyTable)

	for key, value in pairs (tMyTable) do
		fMyFunction (value)
	end

end
--[[
function who
	for n in pairs (_G) do 
		AILib.Emit (tostring (n)) 
	end
end
]]--
-- AILib.Emit(toString(n))
