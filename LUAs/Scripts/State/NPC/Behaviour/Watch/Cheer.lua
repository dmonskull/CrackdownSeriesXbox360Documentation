----------------------------------------------------------------------
-- Name: Cheer State
--	Description: Play a 'cheering' animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

Cheer = Create (TargetState, 
{
	sStateName = "Cheer",
})

function Cheer:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)
	
	self.tHost:SpeakAudio (eVocals.nCheer, "Yeah!")

	-- Face target
	self:PushState (Create (Turn, {}))
end

function Cheer:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		self:ChangeState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nHarass,
		}))
		return true

	elseif self:IsInState (FullBodyAnimate) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
