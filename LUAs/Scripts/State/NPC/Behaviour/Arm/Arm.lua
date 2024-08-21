----------------------------------------------------------------------
-- Name: Arm State
-- Description: Equip with current weapon
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Equipment\\EquipItem"

Arm = Create (State, 
{
	sStateName = "Arm",
})

function Arm:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Equip with the current primary weapon
	local tFirearm = self.tHost:RetCurrentPrimaryEquipment ()
	if tFirearm then
		self:PushState (Create (EquipItem, 
		{
			tEquipment = tFirearm,
		}))
	else
		self:Finish ()
	end

end

function Arm:OnActiveStateFinished ()

	if self:IsInState (EquipItem) then

		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end
