require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Action\\Equipment\\EquipItem"
require "State\\NPC\\Action\\Idle\\Idle"

MikeState = Create (State,
{
	sStateName = "MikeState",
})

function MikeState:OnEnter ()
	State.OnEnter (self)

	self:PushState (Create (EquipItem, 
	{ 
		tEquipment = self.tEquipment,
	}))
end

function MikeState:OnActiveStateFinished ()

	if self:IsInState (EquipItem) then

		self:ChangeState (Create (Idle, {}))
		return true

	end

	return State.OnActiveStateFinished (self)
end

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier2")
local tEquipment = tNPC:AddEquipment ("M16")

tNPC:SetState (Create (MikeState, 
{ 
	tEquipment = tEquipment,
}))
