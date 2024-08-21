----------------------------------------------------------------------
-- Name: PropAttack State
--	Description: Walk to a prop, pick it up, and throw it at the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Objects\\Throw"
require "State\\NPC\\Action\\Objects\\MoveToAndPickUp"
require "State\\NPC\\Action\\Objects\\Drop"

PropAttack = Create (TargetState, 
{
	sStateName = "PropAttack",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	bSuccess = false,
})

function PropAttack:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.tProp)

	-- Run to the prop and pick it up
	self:PushState (Create (MoveToAndPickUp,	
	{
		tTarget = self.tProp,
		nMovementType = self.nMovementType,
		nMovementPriority = self.nMovementPriority,
	}))

	-- Subscribe events
	self.nCarriedObjectLostID = self:Subscribe (eEventType.AIE_CARRIED_OBJECT_LOST, self.tHost)
end

function PropAttack:OnExit ()
	-- Call parent
	TargetState.OnExit (self)

	-- Make sure we don't leave the state carrying the prop
	if self.tHost:RetCarriedObject () == self.tProp then
		self.tHost:DropItemImmediately ()
	end
end

function PropAttack:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Prop was dropped while state was paused
	if self:IsInState (Turn) or self:IsInState (Throw) then
		if self.tHost:RetCarriedObject () ~= self.tProp then
			self.bSuccess = false
			self:Finish ()
		end
	end

end

function PropAttack:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()

	if tState:IsA (MoveToAndPickUp) then

		-- Turn to face the target
		if tState:Success () then
			self:ChangeState (Create (Turn, {}))
		else
			self.bSuccess = false
			self:Finish ()
		end
		return true

	elseif tState:IsA (Turn) then

		-- Throw the prop at the target
		self:ChangeState (Create (Throw, {}))
		return true

	elseif tState:IsA (Throw) then

		-- If we were not able to throw it, drop it
		if tState:Success () then
			self.bSuccess = true
			self:Finish ()
		else
			self:ChangeState (Create (Drop, {}))
		end
		return true

	elseif tState:IsA (Drop) then

		self.bSuccess = false
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function PropAttack:OnEvent (tEvent)

	if tEvent:HasID (self.nCarriedObjectLostID) then

		-- Prop was shot out of my hands - fail
		if tEvent:RetCarriedObject () == self.tProp then
			self.bSuccess = false
			self:Finish ()
		end
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function PropAttack:Success ()
	return self.bSuccess
end
