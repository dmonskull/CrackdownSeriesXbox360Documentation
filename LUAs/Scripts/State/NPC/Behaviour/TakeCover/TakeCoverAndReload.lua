----------------------------------------------------------------------
-- Name: TakeCoverAndReload State
--	Description: Same as TakeCover, but reloads weapon once in cover
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\TakeCover\\TakeCover"
require "State\\NPC\\Action\\Equipment\\Reload"
require "State\\NPC\\Action\\Crouch\\Uncrouch"

TakeCoverAndReload = Create (TakeCover, 
{
	sStateName = "TakeCoverAndReload",
	bCrouchAllowed = true,
})

function TakeCoverAndReload:OnActiveStateFinished ()

	local tState = self:RetActiveState ()
	
	if tState:IsA (Turn) then

		-- Reload
		self:ChangeState (Create (Reload, {}))		
		return true
	
	elseif tState:IsA (Reload) then

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

	return TakeCover.OnActiveStateFinished (self)
end
