----------------------------------------------------------------------
-- Name: RandomWalkTestLaunch
-- Description: Script to launch the RandomWalkTest script
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Test\\TestScripts\\RandomWalkTest"

local tPlayer = cPlayer:RetLocalPlayer ()
tPlayer:SetState (Create (RandomWalkTest, {}))
