----------------------------------------------------------------------
-- Name: FightState
-- Description: Base class for fighting states
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

FightState = Create (TargetState, 
{
	sStateName = "FightState",
	bTargetLost = false,
})

function FightState:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Re-evaluate conditions
	self:EvaluateConditions ()
end

function FightState:OnActiveStateChanged ()
	-- Re-evaluate conditions
	self:EvaluateConditions ()

	-- Call parent
	TargetState.OnActiveStateChanged (self)
end

function FightState:EvaluateConditions ()
	return false
end

function FightState:TargetLost ()
	return self.bTargetLost
end
