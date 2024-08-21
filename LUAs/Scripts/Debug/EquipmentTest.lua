----------------------------------------------------------------------
-- Name: EquipmentTest Script
--	Description:
-- 1. Spawns an NPC with an M16 in his inventory
-- 2. The NPC takes out the M16
-- 3. The NPC shoots once at a point 10 metres in front of him
-- 4. The NPC puts away the M16
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Action\\Equipment\\PrimaryFire"
require "State\\NPC\\Action\\Equipment\\EquipItem"
require "State\\NPC\\Action\\Equipment\\StoreItem"

EquipmentTest = Create (State,
{
	sStateName = "EquipmentTest",
})

function EquipmentTest:OnEnter ()
	State.OnEnter (self)
	AILib.Emit ("Equiping with weapon")
	self:PushState (Create (EquipItem,
	{
		tEquipment = self.tFirearm,
	}))
end

function EquipmentTest:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (EquipItem) then

		AILib.Emit ("Firing weapon")
		local vPosition = self.tHost:RetPosFromYaw (10, self.tHost:RetHeading ())

		self:ChangeState (Create (PrimaryFire,
		{
			vTargetPosition = VecAdd (vPosition, vYAxis),
		}))
		return true

	elseif tState:IsA (PrimaryFire) then

		if tState:Success () then
			AILib.Emit ("Storing weapon")
			self:ChangeState (Create (StoreItem, {}))
		else
			AILib.Emit ("Failed to fire weapon")
			self:Finish ()
		end
		return true

	elseif tState:IsA (StoreItem) then

		AILib.Emit ("TestEquipment completed successfully")
		self:Finish ()
		return true

	end

	return State.OnActiveStateFinished (self)
end

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
local tFirearm = tNPC:AddEquipment ("M16")

tNPC:SetState (Create (EquipmentTest, 
{
	tFirearm = tFirearm,
}))
