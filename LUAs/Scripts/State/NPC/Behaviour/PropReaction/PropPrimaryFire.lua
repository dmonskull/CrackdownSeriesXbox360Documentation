----------------------------------------------------------------------
-- Name: PropPrimaryFire State
-- Description: Try to shoot the prop out of the air
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Equipment\\PrimaryFire"

PropPrimaryFire = Create (TargetState, 
{
	sStateName = "PropPrimaryFire",
	nCount = 10,
})

function PropPrimaryFire:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)
	
	-- Shoot the prop
	-- This state shoots whether the prop is in range or not, which looks better
	self:PushState (Create (PrimaryFire, {}))
end

function PropPrimaryFire:OnActiveStateFinished ()

	if self:IsInState (PrimaryFire) then

		-- Decrement counter
		self.nCount = self.nCount - 1

		-- Stop firing if we run out of ammo or the counter reaches 0
		local tEquipment = self.tHost:RetCurrentPrimaryEquipment ()
		if tEquipment and not tEquipment:IsEmpty () and	self.nCount > 0 then
			self:ChangeState (Create (PrimaryFire, {}))
		else
			self:Finish ()
		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
