----------------------------------------------------------------------
-- Name: TargetState State
--	Description: Handles a few useful functions common to all NPC states
-- that require a target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

TargetState = Create (State,
{
	sStateName = "TargetState",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks,
	bTargetMandatory = true,	-- Specify this to assert if there is no target
	bTargetDeleted = false,		-- Will be set to true if the target was deleted
	tTarget = nil,				-- Specify either tTarget or vTargetPosition to
	vTargetPosition = nil,		-- push a new target onto the stack
})

function TargetState:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	if self.tTarget then
		-- If a target is specified explicitly then push it onto the target stack
		assert (self.tTarget ~= self.tHost)
		self.tTargetInfo = self.tHost:PushTarget (self.tTarget, self.nTargetInfoFlags)

	elseif self.vTargetPosition then
		-- If a target position is specified explicitly then push it onto the target stack
		self.tTargetInfo = self.tHost:PushTargetPosition (self.vTargetPosition, self.nTargetInfoFlags)

	elseif self.tHost:RetTargetInfo () then
		-- No target specified so use the one currently at the top of the stack
		self.tTargetInfo = self.tHost:RetTargetInfo ()
		self.tTargetInfo:AddReference ()
		self.tTargetInfo:SetFlags (self.nTargetInfoFlags)

	else
		-- No target specified and none exist on stack - error
		assert (not self.bTargetMandatory)

	end

	-- If the target is mandatory, and if it is set explicitly then the state will finish if it is deleted
	if self.tTarget and self.bTargetMandatory then
		self.nTargetDeletedID = self:Subscribe (eEventType.AIE_OBJECT_DELETED, self.tTarget)
	end

end

function TargetState:OnExit ()
	-- Call parent
	State.OnExit (self)

	-- Decrement reference counters for the options specified by the flags
	if self.tTargetInfo then
		self.tTargetInfo:ClearFlags (self.nTargetInfoFlags)
		self.tTargetInfo:RemoveReference ()
	end

	-- If a target was pushed onto the stack in the OnEnter function
	-- then pop it from the stack here
	if self.tTarget or self.vTargetPosition then
		self.tTargetInfo = nil
		self.tHost:PopTarget ()
	end
end

function TargetState:OnEvent (tEvent)

	-- If the target is mandatory, and if it is set explicitly then the state will finish if it is deleted
	if self.nTargetDeletedID and tEvent:HasID (self.nTargetDeletedID) then

		self.bTargetDeleted = true
		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function TargetState:TargetDeleted ()
	return self.bTargetDeleted
end
