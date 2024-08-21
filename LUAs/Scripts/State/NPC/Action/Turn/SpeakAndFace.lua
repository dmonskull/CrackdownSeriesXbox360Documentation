----------------------------------------------------------------------
-- Name: SpeakAndFace State
--	Description: Face the target and say something - the state finishes
-- when the sound finishes (hard-coded to 4 seconds for now)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Turn\\WaitAndFace"

SpeakAndFace = Create (WaitAndFace, 
{
	sStateName = "SpeakAndFace",
	nVocal = eVocals.nNoVocal,
	nWaitTime = 4,
})

function SpeakAndFace:OnEnter ()
	-- Call parent
	WaitAndFace.OnEnter (self)

	-- Check parameters
	assert (self.sSentence)

	-- Speak
	self.tHost:SpeakAudio (self.nVocal, self.sSentence)
end
