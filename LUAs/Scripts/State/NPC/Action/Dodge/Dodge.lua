----------------------------------------------------------------------
-- Name: Dodge State
--	Description: Dodge out the way of the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Dodge = Create (TargetState, 
{
	sStateName = "Dodge",
	nMovementType = eMovementType.nSprint,
	nMovementPriority = eMovementPriority.nLow,
})

function Dodge:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to events
	self.nDodgeFinishedID = self:Subscribe (eEventType.AIE_DODGE_FINISHED, self.tHost)

	self:OnResume ()
end

function Dodge:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set speed
	self.tHost:SetMovementType (self.nMovementType)

	-- Set priority
	self.tHost:SetMovementPriority (self.nMovementPriority)

	-- Go into Dodge brain state
	self.tHost:Dodge ()
end

function Dodge:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Dodge:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Dodge:OnEvent (tEvent)

	-- The object has gone past me
	if tEvent:HasID (self.nDodgeFinishedID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
