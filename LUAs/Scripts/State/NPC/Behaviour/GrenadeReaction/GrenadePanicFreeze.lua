----------------------------------------------------------------------
-- Name: PanicFreeze State
--	Description: Play a looping panic animation until the grenade explodes
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

GrenadePanicFreeze = Create (FullBodyAnimate, 
{
	sStateName = "GrenadePanicFreeze",
	anPanicFreezeAnimList =
	{
		eFullBodyAnimationID.nPanicFreeze1,
		eFullBodyAnimationID.nPanicFreeze2,
		eFullBodyAnimationID.nPanicFreeze3,
	},
})

function GrenadePanicFreeze:OnEnter ()
	-- Pick a random animation from the table
	local nIndex = cAIPlayer.Rand (1, table.getn (self.anPanicFreezeAnimList))

	self.nAnimationID = self.anPanicFreezeAnimList[nIndex]

	-- Call parent
	FullBodyAnimate.OnEnter (self)
end
