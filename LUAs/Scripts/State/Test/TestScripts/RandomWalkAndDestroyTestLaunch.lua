----------------------------------------------------------------------
-- Name: RandomWalkAndDestroyTestLaunch
-- Description: Script to launch the RandomWalkAndDestroyTest script
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Test\\TestScripts\\RandomWalkAndDestroyTest"

local tPlayer = cPlayer:RetLocalPlayer ()
tPlayer:SetState (Create (RandomWalkAndDestroyTest, {}))
