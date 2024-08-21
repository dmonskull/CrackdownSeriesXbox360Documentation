----------------------------------------------------------------------
-- Name: Timers
--	Description: Extends the State class - the state can contain a stack
-- of child-states
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

-- Push the given state onto the top of the stack (implicitly making it the
-- current state.)
function State:PushState (tState)
	assert (self.atStack)

	tState.tParent = self
	tState.tHost = self.tHost

	-- Get index to top of stack
	local nTop = self:RetStackSize ()

	-- Pause the state currently at the top of the stack
	if nTop > 0 then
		self.atStack[nTop]:OnPause ()
	end

	--add tState to the stack
	self.atStack[nTop+1] = tState

	-- Callback to the new state object to tell it that it has just become active.
	self.atStack[nTop+1]:OnEnter ()

	-- Callback to this state to inform it that the active state has changed
	self:OnActiveStateChanged ()
end

-- Pop the current state from the top of the stack, replacing it with the
-- previous state.
function State:PopState ()
	assert (self.atStack)

	-- Get index to top of stack
	local nTop = self:RetStackSize ()

	if nTop > 0 then
		-- Callback to the state being removed to let it perform cleanup.
		self.atStack[nTop]:OnExit ()
	
		--remove the state from the stack
		self.atStack[nTop] = nil
	end

	-- Resume the state beneath it in the stack
	if nTop > 1 then
		self.atStack[nTop-1]:OnResume ()
	end

	-- Callback to this state to inform it that the active state has changed
	self:OnActiveStateChanged ()
end

-- Change currently active state (a pop followed by a push, 
-- but with no resume and pause calls to the state underneath)
function State:ChangeState (tState)
	assert (self.atStack)

	tState.tParent = self
	tState.tHost = self.tHost

	-- Get index to top of stack
	local nTop = self:RetStackSize ()

	assert (nTop > 0)

	-- Callback to the state being removed to let it perform cleanup.
	self.atStack[nTop]:OnExit ()

	--Set the top of the stack to the new state
	self.atStack[nTop] = tState

	-- Callback to the new state object to tell it that it has just become active.
	self.atStack[nTop]:OnEnter ()

	-- Callback to this state to inform it that the active state has changed
	self:OnActiveStateChanged ()
end

-- Pop all the states in the stack
function State:ClearStack ()
	while self:RetStackSize () > 0 do
		self:PopState ()
	end
end

-- Return the stack size
function State:RetStackSize ()
	assert (self.atStack)
	return table.getn (self.atStack)
end

-- Return the state at the top of the stack
function State:RetActiveState ()
	assert (self.atStack)
	if self:RetStackSize () > 0 then
		return self.atStack[self:RetStackSize ()]
	else
		return nil
	end
end

-- Called when a state is pushed on top of this one in the stack - over-ride this
function State:OnPause ()
	-- Pause any timers created by this state
	self:PauseAllTimers ()

	-- Pause state at top of stack
	local tState = self:RetActiveState ()
	if tState then
		tState:OnPause ()
	end
end

-- Called when a state is popped above this one in the stack - over-ride this
function State:OnResume ()
	-- Resume state at top of stack
	local tState = self:RetActiveState ()
	if tState then
		tState:OnResume ()
		self:CheckActiveState ()
	end

	-- Resume any timers create by this state
	self:ResumeAllTimers ()
end

-- Called whenever the state at the top of the stack changes (i.e., by pushing or popping)
function State:OnActiveStateChanged ()
--	if self.tHost:IsA (cCharacterEntityIF) then
--		AILib.Emit (self.tHost:RetName () .. ": " .. self.tHost:RetDebugString ())
--	else
--		AILib.Emit (self.tHost:RetDebugString ())
--	end
	self.bActiveStateLocked = self:IsActiveStateLocked ()
	self:CheckActiveState ()
end

-- Called whenever the state at the top of the stack finishes itself - over-ride this
function State:OnActiveStateFinished ()
	self:PopState ()
	return true
end

-- Called by the state at the top of the stack when it wants to finish itself
function State:Finish ()
	self.bStateFinished = true
end

-- Checks the state at the top of the stack to see if it is finished or unlocked
function State:CheckActiveState ()
	-- Check to see if the state is finished
	local tState = self:RetActiveState ()
	if tState and tState.bStateFinished then
		self:OnActiveStateFinished ()
	end

	-- Check if the state's locked status has changed
	local bNewActiveStateLocked = self:IsActiveStateLocked ()
	if self.bActiveStateLocked and not bNewActiveStateLocked then
		self:OnActiveStateUnlocked ()
	end
	self.bActiveStateLocked = bNewActiveStateLocked
end

-- Search the tree above me to find the first parent state of a specific type
function State:RetParentOfType (Type)
	if not self.tParent then
		return nil
	elseif self.tParent:IsA (Type) then
		return self.tParent
	else
		return self.tParent:RetParentOfType (Type)
	end
end

-- Return true if the active state is of the specified type
function State:IsInState (Type)
	local tState = self:RetActiveState ()
	if tState and tState:IsA (Type) then
		return true
	else
		return false
	end
end

-- Called whenever the state at the top of the stack unlocks itself - over-ride this
function State:OnActiveStateUnlocked ()
end

-- Return true if the state is 'locked' i.e. it doesn't want to be exited
function State:IsLocked ()
	return false
end

-- Return true if the active state is 'locked' i.e. it doesn't want to be exited
function State:IsActiveStateLocked ()
	local tState = self:RetActiveState ()
	if tState and tState:IsLocked () then
		return true
	else
		return false
	end
end
