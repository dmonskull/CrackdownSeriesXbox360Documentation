----------------------------------------------------------------------
-- Name: GrenadeAttack State
--	Description: Take a grenade from the inventory and throw it at the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Equipment\\SecondaryFire"

GrenadeAttack = Create (TargetState, 
{
	sStateName = "GrenadeAttack",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks,
})

function GrenadeAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Turn to face target
	self:PushState (Create (Turn, {}))
end

function GrenadeAttack:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	if tState:IsA (Turn) then

		-- Throw the grenade at the target
		self:ChangeState (Create (SecondaryFire, {}))
		return true

	elseif tState:IsA (SecondaryFire) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
