----------------------------------------------------------------------
-- Name: Speak State
--	Description: Say something - the state finishes when the sound finishes 
-- (hard-coded to 4 seconds for now)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Idle\\Wait"

Speak = Create (Wait, 
{
	sStateName = "Speak",
	nVocal = eVocals.nNoVocal,
	nWaitTime = 4,
})

function Speak:OnEnter ()
	-- Call parent
	Wait.OnEnter (self)

	-- Check parameters
	assert (self.sSentence)

	-- Speak
	self.tHost:SpeakAudio (self.nVocal, self.sSentence)
end
