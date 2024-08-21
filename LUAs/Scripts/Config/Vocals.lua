----------------------------------------------------------------------
-- Name: Vocals
-- Description: A list of all character vocal events. Must be identical to enum in cAudioVocalsProfile.h
-- Owner: Roland
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\ReadOnly"

eVocals = CreateReadOnly
{
	nVocalUnused = 0,
	nDeath = 1,
	nPain = 2,
	nInvestigating = 3,
	nHeard = 4,
	nSorry = 5,
	nLostThem = 6,
	nInsult = 7,
	nThankYou = 8,
	nVictory = 9,
	nWarn = 10,
	nInsultDead = 11,
	nBoo = 12,
	nCheer = 13,
	nFoundCorpse = 14,
	-- NB: this list must be kept identical to enum in cAudioVocalsProfile.h

	-- this one used for Speak commands that don't have audible vocals
	nNoVocal = 15,
}

