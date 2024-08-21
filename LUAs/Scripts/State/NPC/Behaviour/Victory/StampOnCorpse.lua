----------------------------------------------------------------------
-- Name: StampOnCorpse State
--	Description: Walk to the body and kick it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Combat\\MoveToAndCloseAttack"

StampOnCorpse = Create (MoveToAndCloseAttack, 
{
	sStateName = "StampOnCorpse",
	nMovementType = eMovementType.nWalk,
})

function StampOnCorpse:OnEnter ()
	-- Set the number of times to stamp
	self.nCount = 1

	-- Set the time to wait before starting the stamping
	self.nReactionTime = 4

	-- Call parent
	MoveToAndCloseAttack.OnEnter (self)
end

function StampOnCorpse:OnActiveStateChanged ()

	if self:IsInState (WaitAndFace) then
		self.tHost:SpeakAudio (eVocals.nInsultDead, "Hey, what's the matter asshole?")
	end

	-- Call parent
	MoveToAndCloseAttack.OnActiveStateChanged (self)
end
