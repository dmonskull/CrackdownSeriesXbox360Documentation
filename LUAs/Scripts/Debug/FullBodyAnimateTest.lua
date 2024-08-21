----------------------------------------------------------------------
-- Name: FullBodyAnimateTest Script
--	Description:
-- 1. Spawns an NPC
-- 2. The NPC plays a full body animation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

FullBodyAnimateTest = Create (State,
{
	sStateName = "FullBodyAnimateTest",
})

function FullBodyAnimateTest:OnEnter ()
	State.OnEnter (self)
	self:PushState (Create (FullBodyAnimate,
	{
		nAnimationID = eFullBodyAnimationID.nHarass,
		bLooping = true,
		bBlockInterrupts = false,
	}))
end

function FullBodyAnimateTest:OnActiveStateFinished ()

	if self:IsInState (FullBodyAnimate) then

		AILib.Emit ("FullBodyAnimateTest completed successfully")
		self:Finish ()
		return true

	end

	return State.OnActiveStateFinished (self)
end

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier5", nil, 5)

tNPC:SetState (FullBodyAnimateTest)
