----------------------------------------------------------------------
-- Name: LookAround State
--	Description: Turn to face various different directions in order to try and
-- spot enemies who aren't conveniently in my view cone
-- TODO - could we use accessways data or something clever for this?
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

LookAround = Create (FullBodyAnimate, 
{
	sStateName = "LookAround",
	nAnimationID = eFullBodyAnimationID.nLookAround,
})
