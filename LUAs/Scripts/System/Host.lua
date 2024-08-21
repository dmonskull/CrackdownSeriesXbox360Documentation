require ("System\\State")

Host = Create (BaseObject,
{
	tCurrentState = nil
})

function Host:Subscribe (sEventName, tSourceFilter)
	return HostLib.HostSubscribe (self, sEventName, tSourceFilter)
end

function Host:SubscribeImmediate (sEventName, tSourceFilter)
	return HostLib.HostSubscribeImmediate (self, sEventName, tSourceFilter)
end

function Host:Unsubscribe (nEventID, sEventName)
	HostLib.HostUnsubscribe (self, nEventID, sEventName)
end

function Host:OnEvent (tEvent)
	if self.tCurrentState then
		if self.tCurrentState:OnEvent (tEvent) then
			self:CheckCurrentState ()
			return true
		end
	end
	return false
end

function Host:SetState (tNewState)
	if self.tCurrentState then
		self.tCurrentState:OnExit ()
	end

	self.tCurrentState = Create (tNewState, 
	{
		tHost = self
	})

	self.tCurrentState:OnEnter ()
	self:CheckCurrentState ()

end

function Host:ClearState ()
	if self.tCurrentState then
		self.tCurrentState:OnExit ()
		self.tCurrentState = nil
	end
end

function Host:RetState ()
	return self.tCurrentState
end

function Host:IsInState (Type)
	return self.tCurrentState and self.tCurrentState:IsA (Type)
end

function Host:OnCurrentStateFinished ()
	-- Perform clean up tasks for the state
	self.tCurrentState:OnExit ()

	-- Trigger an event saying that the current state is finished
	local tCustomEvent = self:NotifyCustomEvent ("StateFinished")
	
	-- Attach a pointer to the state to the event
	tCustomEvent.tState = self.tCurrentState

	-- Destroy our pointer to the state - when the event is destroyed the state will be de-allocated
	self.tCurrentState = nil
	return true
end

function Host:CheckCurrentState ()
	if self.tCurrentState.bStateFinished then
		self:OnCurrentStateFinished ()
	end
end

function Host:Terminate ()
	if self.tCurrentState then
		self.tCurrentState:OnExit ()
	end
	
	self.HostDeleted = true
end

function Host:IsDeleted ()
	return self.HostDeleted == true
end

function Host:RetDebugString ()
	if self.tCurrentState then
		return self.tCurrentState:RetDebugString ()
	else
		return ""
	end
end

function Host:OnCompress ()
	if self.tCurrentState then
		self.tCurrentState:OnCompress ()
	end
end

function Host:OnUncompress ()
	if self.tCurrentState then
		self.tCurrentState:OnUncompress ()
	end
end
