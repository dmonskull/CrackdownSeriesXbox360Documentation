----------------------------------------------------------------------
-- Name: GiveUpSearch State
--	Description: Play a 'giving up' animation and say something to indicate
-- I am giving up the search
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

GiveUpSearch = Create (FullBodyAnimate, 
{
	sStateName = "GiveUpSearch",
	nAnimationID = eFullBodyAnimationID.nGiveUp,
})

function GiveUpSearch:OnEnter ()
	-- Call parent
	FullBodyAnimate.OnEnter (self)
	
	self.tHost:SpeakAudio (eVocals.nLostThem, "Damn, looks like we lost him")
end
