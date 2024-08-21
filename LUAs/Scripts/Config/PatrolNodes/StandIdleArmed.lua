----------------------------------------------------------------------
-- Name: Stand idle armed patrol node
-- Description: Guard stands idle for the specified amount of time
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

----------------------------------------------------------------------
-- This script is to be run from a patrol node
-- Required paramters from the patrol node are:
--	Duration ( a duration of 0 means forever )
--	Direction
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\StandIdleArmed"


return function (tState, tNodeProperties)

	local nNodeDuration = tNodeProperties.nDuration
	local nUseTimeout = true
	if nNodeDuration == 0 then
		nUseTimeout = false
	end
	
	local vNodePosition = tNodeProperties.vPosition
	local vNodeDirection = tNodeProperties.vDirection
	local vTargetPoint = VecAdd (vNodePosition, VecMultiply (vNodeDirection, 10))
	
	tState:PushState (Create (StandIdleArmed,
	{
		bTimeout = nUseTimeout,
		nTimeoutDuration = nNodeDuration,
		bFaceTargetPoint = true,
		vFaceTargetPoint = vTargetPoint,
	}))
	
	return true
	
end
