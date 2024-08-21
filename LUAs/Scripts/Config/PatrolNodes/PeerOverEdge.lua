----------------------------------------------------------------------
-- Name: Peer Over Edge patrol node
-- Description: Guard stands and peers over an edge
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

----------------------------------------------------------------------
-- This script is to be run from a patrol node
-- Required paramters from the patrol node are:
--	Duration
--	Direction
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\TurnAndFullBodyAnimate"


return function (tState, tNodeProperties)
	local nNodeDuration = tNodeProperties.nDuration
	local nPreIdleDuration = nNodeDuration / 2
	local nPostIdleDuration = nNodeDuration / 2

	local vNodePosition = tNodeProperties.vPosition
	local vNodeDirection = tNodeProperties.vDirection
	local vTargetPoint = VecAdd (vNodePosition, VecMultiply (vNodeDirection, 10))
	
	tState:PushState (Create (TurnAndFullBodyAnimate,
	{
		vFaceTargetPoint = vTargetPoint,
		nAnimationID = eFullBodyAnimationID.nPeerOverEdge,
		nPreIdleTime = nPreIdleDuration,
		nPostIdleTime = nPostIdleDuration,
	}))
	
	return true
	
end
