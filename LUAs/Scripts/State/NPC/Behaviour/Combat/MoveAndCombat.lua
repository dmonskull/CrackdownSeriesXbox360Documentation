----------------------------------------------------------------------
-- Name: MoveAndCombat State
-- Description: Move to a position, then start fighting
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Behaviour\\Attack\\MoveAndAttack"

MoveAndCombat = Create (Combat,
{
	sStateName = "MoveAndCombat",
})

function MoveAndCombat:OnEnter ()
	-- Check parameters
	assert (self.vDestination)

	-- Call parent
	Combat.OnEnter (self)
end

function MoveAndCombat:OnActiveStateFinished ()
	
	if self:IsInState (ArmWithBestWeapon) then

		-- Run to the destination position, while shooting at the target if there is one
		self:ChangeState (Create (MoveAndAttack,
		{
			vDestination = self.vDestination,
			bCanTakeCover = self.bCanTakeCover,
		}))
		return true

	elseif self:IsInState (MoveAndAttack) then

		self:ChangeState (self:CreateFightState ())
		return true

	end

	-- Call parent
	return Combat.OnActiveStateFinished (self)
end
