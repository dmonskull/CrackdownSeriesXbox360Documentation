----------------------------------------------------------------------
-- Name: WaitAndListen State
--	Description: Listen for a specified period of time
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Listen\\Listen"
require "State\\NPC\\Action\\Turn\\WaitAndFace"

WaitAndListen = Create (Listen, 
{
	sStateName = "WaitAndListen",
})

function WaitAndListen:OnEnter ()
	-- Check parameters
	assert (self.nWaitTime)

	-- Call parent
	Listen.OnEnter (self)
end

function WaitAndListen:CreateFaceState (vPosition)
	return Create (WaitAndFace,
	{
		vTargetPosition = vPosition,
		nWaitTime = self.nWaitTime,
	})
end

function WaitAndListen:OnActiveStateFinished ()

	if self:IsInState (WaitAndFace) then

		self:Finish ()
		return true

	end

	-- Call parent
	return Listen.OnActiveStateFinished (self)
end
