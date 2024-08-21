----------------------------------------------------------------------
-- Name: PropThrowTest Script
--	Description:
-- 1. Spawns an NPC and a prop
-- 2. The NPC walks towards the prop
-- 3. The NPC picks up the prop
-- 4. The NPC Turns to face the player
-- 5. The NPC throws the prop at the player
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "System\\State"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Objects\\Throw"
require "State\\NPC\\Action\\Objects\\MoveToAndPickUp"

PropThrowTest = Create (State,
{
	sStateName = "PropThrowTest",
})

function PropThrowTest:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Walk to the prop and pick it up
	AILib.Emit ("Moving to and picking up prop")
	self:PushState (Create (MoveToAndPickUp,	
	{
		tTarget = self.tProp
	}))
end

function PropThrowTest:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	if tState:IsA (MoveToAndPickUp) then

		-- Turn to face the player
		if tState:Success () then
			AILib.Emit ("Turning to face target")
			self:ChangeState (Create (Turn, 
			{
				tTarget = self.tAttackTarget,
			}))
		else
			AILib.Emit ("Failed to pick up prop")
			self:Finish ()
		end
		return true

	elseif tState:IsA (Turn) then

		-- Throw the prop at the target
		AILib.Emit ("Throwing prop")
		self:ChangeState (Create (Throw, 
		{
			tTarget = self.tAttackTarget,
		}))
		return true

	elseif tState:IsA (Throw) then

		-- If we were not able to throw it, drop it
		if tState:Success () then
			AILib.Emit ("PropThrowTest completed successfully")
		else
			AILib.Emit ("Failed to throw prop")
		end
		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

local tAiManager = cAiManager.RetAiManager ()
local tPlayer = tAiManager:RetPlayer (0)

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
local tProp = SpawnInFrontOfPlayer ("PROP_Barrel_Blue_001", 15)

tNPC:SetState (Create (PropThrowTest,
{
	tProp = tProp,
	tAttackTarget = tPlayer,
}))
