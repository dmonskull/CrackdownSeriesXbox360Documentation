----------------------------------------------------------------------
-- Name: PropTest Script
--	Description:
-- 1. Spawns an NPC and a prop
-- 2. The NPC walks towards the prop
-- 3. The NPC picks up the prop
-- 4. The NPC does nothing for 2 seconds
-- 5. The NPC drops the prop
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Objects\\MoveToAndPickUp"
require "State\\NPC\\Action\\Objects\\Drop"
require "State\\NPC\\Action\\Idle\\Wait"

PropTest = Create (TargetState,
{
	sStateName = "PropTest",
})

function PropTest:OnEnter ()
	TargetState.OnEnter (self)
	AILib.Emit ("Moving to and picking up prop")
	self:PushState (Create (MoveToAndPickUp, {}))
end

function PropTest:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (MoveToAndPickUp) then

		if tState:Success () then
			AILib.Emit ("Waiting 2 seconds")
			self:ChangeState (Create (Wait, 
			{
				nWaitTime = 2,
			}))			
		else
			AILib.Emit ("Failed to pick up prop")
			self:Finish ()
		end
		return true

	elseif tState:IsA (Wait) then

		AILib.Emit ("Dropping prop")
		self:ChangeState (Create (Drop, {}))
		return true

	elseif tState:IsA (Drop) then

		if tState:Success () then
			AILib.Emit ("PropTest completed successfully!")
		else
			AILib.Emit ("Failed to drop prop")
		end
		self:Finish ()
		return true

	end
	return TargetState.OnActiveStateFinished (self)

end

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
local tProp = SpawnInFrontOfPlayer ("PROP_Barrel_Blue_001", 15)

tNPC:SetState (Create (PropTest, 
{
	tTarget = tProp,
}))


