----------------------------------------------------------------------
-- Name: TakeCoverAndWait State
--	Description: Starts the same as TakeCover, but pauses for a while
-- after reaching cover.
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\TakeCover\\TakeCover"
require "State\\NPC\\Action\\Equipment\\WaitAndPrimaryFire"
require "State\\NPC\\Action\\Crouch\\Uncrouch"

TakeCoverAndWait = Create (TakeCover, 
{
	sStateName = "TakeCoverAndWait",
	bCrouchAllowed = true,
	nWaitTime = 2,
})

function TakeCoverAndWait:OnActiveStateFinished ()

	local tState = self:RetActiveState ()
	
	if tState:IsA (Turn) then

		-- Wait in cover, but shoot the target if possible
		-- (i.e. the target might have followed us into cover)
		self:ChangeState (Create (WaitAndPrimaryFire,		
		{
			nWaitTime = self.nWaitTime
		}))
		return true
		
	elseif tState:IsA (WaitAndPrimaryFire) then

		if self.bCrouch then
			self:ChangeState (Create (Uncrouch, {}))
		else
			self.bSuccess = true
			self:Finish ()
		end
		return true

	elseif tState:IsA (Uncrouch) then
	
		self.bSuccess = true
		self:Finish ()
		return true
		
	end	

	-- Call parent
	return TakeCover.OnActiveStateFinished (self)
end
