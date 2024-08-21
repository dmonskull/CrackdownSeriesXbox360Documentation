----------------------------------------------------------------------
-- Name: Stand idle patrol node
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

require "State\\NPC\\Behaviour\\StandIdle"


return function (tState, tNodeProperties)

	local nNodeDuration = tNodeProperties.nDuration
	local nUseTimeout = true
	if nNodeDuration == 0 then
		nUseTimeout = false
	end
	
	local vNodePosition = tNodeProperties.vPosition
	local vNodeDirection = tNodeProperties.vDirection
	local vTargetPoint = VecAdd (vNodePosition, VecMultiply (vNodeDirection, 10))
	
	tState:PushState (Create (StandIdle,
	{
		bTimeout = nUseTimeout,
		nTimeoutDuration = nNodeDuration,
		bFaceTargetPoint = true,
		vFaceTargetPoint = vTargetPoint,
		anAnimList =
		{
			eFullBodyAnimationID.nIdle1,
			eFullBodyAnimationID.nIdle3,
			eFullBodyAnimationID.nIdle4,
		},
	}))
	
	return true
	
end
