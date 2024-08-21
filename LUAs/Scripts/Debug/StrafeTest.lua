----------------------------------------------------------------------
-- Name: StrafeTest Script
--	Description:
-- 1. Spawns two NPCs
-- 2. The NPCs walk ten metres in the positive x direction, facing each other
-- 3. The NPCs walk ten metres in the negative x direction, facing each other
-- 4. and repeat
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Movement\\MoveAndFace"

StrafeTest = Create (TargetState,
{
	sStateName = "StrafeTest",
})

function StrafeTest:OnEnter ()
	TargetState.OnEnter (self)

	self.vOffset = MakeVec3 (10, 0, 0)

	self:PushState (Create (MoveAndFace,
	{
		nMovementType = eMovementType.nWalk,
		vDestination = VecAdd (self.vOffset, self.tHost:RetPosition ()),
	}))
end

function StrafeTest:OnActiveStateFinished ()
	-- Swap offset in the other direction
	self.vOffset = VecSubtract (vOrigin, self.vOffset)

	self:ChangeState (Create (MoveAndFace,
	{
		nMovementType = eMovementType.nWalk,
		vDestination = VecAdd (self.vOffset, self.tHost:RetPosition ()),
	}))

	return true
end

local tNPC1 = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
local tNPC2 = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 10)

tNPC1:SetState (Create (StrafeTest,
{
	tTarget = tNPC2,
}))

tNPC2:SetState (Create (StrafeTest,
{
	tTarget = tNPC1,
}))
