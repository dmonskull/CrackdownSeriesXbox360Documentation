_LOADED = {}		-- empties the list of loaded files.

require "State\\NPC\\Action\\Vehicles\\Driveto"
require "Debug\\Sams\\Sam_Common"

local tAiManager = cAiManager.RetAiManager ()
local tPlayer = tAiManager:RetPlayer (0)
--local tSecondPlayer = tAiManager:RetSecondPlayer (0)
--player character will go to this position

-- Midtown
--tPlayer:ForcePos(964,55,-1565)

-- NorthIsland
--tPlayer:ForcePos(609.3, 62.1, -2646.6)
tPlayer:ForcePos(1008, 48, -1565)
--tPlayer:ForcePos(1324, 13, -2432)
--tPlayer:ForcePos(1039, 23, -2382)
--tPlayer:ForcePos(1036, 22, -2388)
--tSecondPlayer:ForcePos(1036, 22, -2388)