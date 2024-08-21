----------------------------------------------------------------------
-- Name: Stand listening patrol node
-- Description: Guard stands listening for the specified amount of time
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

----------------------------------------------------------------------
-- This script is to be run from a patrol node
-- Required paramters from the patrol node are:
--	Duration ( a duration of 0 means forever )
--	Direction
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\TurnAndUpperBodyAnimate"


return function (tState, tNodeProperties)

	local nNodeDuration = tNodeProperties.nDuration
	local nPreIdleDuration = nNodeDuration / 2
	local nPostIdleDuration = nNodeDuration / 2
	
	local vNodePosition = tNodeProperties.vPosition
	local vNodeDirection = tNodeProperties.vDirection
	local vTargetPoint = VecAdd (vNodePosition, VecMultiply (vNodeDirection, 10))
	
	tState:PushState (Create (TurnAndUpperBodyAnimate,
	{
		nPreIdleTime = nPreIdleDuration,
		nPostIdleTime = nPostIdleDuration,
		vFaceTargetPoint = vTargetPoint,
		nAnimationID = eUpperBodyAnimationID.nStandingListening,
	}))
	
	return true
	
end
