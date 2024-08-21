----------------------------------------------------------------------
-- Name: Boo State
--	Description: Play a 'booing' animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

Boo = Create (TargetState, 
{
	sStateName = "Boo",
})

function Boo:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)
	
	self.tHost:SpeakAudio (eVocals.nBoo, "Boo! Hiss!")

	-- Face target
	self:PushState (Create (Turn, {}))
end

function Boo:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		self:ChangeState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nTaunt3,
		}))
		return true

	elseif self:IsInState (FullBodyAnimate) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
