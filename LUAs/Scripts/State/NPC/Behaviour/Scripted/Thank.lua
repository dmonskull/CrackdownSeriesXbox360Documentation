----------------------------------------------------------------------
-- Name: Thank State
--	Description: Thank the player for saving them from the evil gangsters
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

Thank = Create (TargetState, 
{
	sStateName = "Thank",
})

function Thank:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Turn to face the target
	self:PushState (Create (Turn, {}))
end

function Thank:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		-- Play apologising animation
		self.tHost:SpeakAudio (eVocals.nThankYou, "You're my hero!")
		self:ChangeState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nThank,
		}))
		return true

	elseif self:IsInState (FullBodyAnimate) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
