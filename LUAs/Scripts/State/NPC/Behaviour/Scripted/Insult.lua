----------------------------------------------------------------------
-- Name: Insult State
--	Description: Play an 'insult' animation and say something appropriate
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

Insult = Create (FullBodyAnimate, 
{
	sStateName = "Insult",
	anAnimList =
	{
		eFullBodyAnimationID.nHarass,
		eFullBodyAnimationID.nTaunt1,
		eFullBodyAnimationID.nTaunt2,
		eFullBodyAnimationID.nTaunt3,
		eFullBodyAnimationID.nTaunt4,
		eFullBodyAnimationID.nTaunt5,
	},
})

function Insult:OnEnter ()
	-- Pick a random animation from the table
	local nIndex = cAIPlayer.Rand (1, table.getn (self.anAnimList))

	-- Pick a random taunt animation
	self.nAnimationID = self.anAnimList[nIndex]

	-- Call parent
	FullBodyAnimate.OnEnter (self)
	
	self.tHost:SpeakAudio (eVocals.nInsult, "Come and fight me, you pathetic girlie-man!")
end
