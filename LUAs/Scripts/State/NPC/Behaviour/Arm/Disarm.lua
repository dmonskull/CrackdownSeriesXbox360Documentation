----------------------------------------------------------------------
-- Name: Disarm State
--	Description: Store weapon
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Equipment\\StoreItem"

Disarm = Create (State, 
{
	sStateName = "Disarm",
})

function Disarm:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Am I holding a weapon?
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () then
		self:PushState (Create (StoreItem, {}))
	else
		self:Finish ()
	end

end

function Disarm:OnActiveStateFinished ()

	if self:IsInState (StoreItem) then

		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end
