----------------------------------------------------------------------
-- Name: SpitOnCorpse State
--	Description: Walk to the body and play a spitting animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

SpitOnCorpse = Create (TargetState, 
{
	sStateName = "SpitOnCorpse",
})

function SpitOnCorpse:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)
	
	self:PushState (Create (GetInProximity, 
	{
		nMovementType = eMovementType.nWalk,
		nRadius = 3,
	}))
end

function SpitOnCorpse:OnActiveStateFinished ()

	if self:IsInState (GetInProximity) then

		self:ChangeState (Create (Turn, {}))
		return true

	elseif self:IsInState (Turn) then

		self.tHost:SpeakAudio (eVocals.nInsultDead, "Think you can fuck with me, heh?")
		self:ChangeState (Create (FullBodyAnimate, 
		{
			nAnimationID = eFullBodyAnimationID.nVictory,
		}))
		return true

	elseif self:IsInState (FullBodyAnimate) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
