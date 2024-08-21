----------------------------------------------------------------------
-- Name: RandomDriveTestLaunch
-- Description: Script to launch the RandomDriveTest script
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Test\\TestScripts\\RandomDriveTest"

local tPlayer = cPlayer:RetLocalPlayer ()
tPlayer:SetState (Create (RandomDriveTest, {}))
