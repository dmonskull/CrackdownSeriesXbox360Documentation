----------------------------------------------------------------------
-- Name: Apologise State
--	Description: Apologise and walk away
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Animation\\BackAway"

Apologise = Create (TargetState, 
{
	sStateName = "Apologise",
})

function Apologise:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Turn to face the target
	self:PushState (Create (Turn, {}))
end

function Apologise:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		-- Play apologising animation
		self.tHost:SpeakAudio (eVocals.nSorry, "Sorry")
		self:ChangeState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nBackOff,
		}))
		return true

	elseif self:IsInState (FullBodyAnimate) then

		-- Walk away
		self:ChangeState (Create (BackAway,	{}))
		return true

	elseif self:IsInState (BackAway) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
