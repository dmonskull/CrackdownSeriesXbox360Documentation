----------------------------------------------------------------------
-- Name: BackAway State
--	Description: NPC backs away from target (playing a scared animation)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

BackAway = Create (TargetState, 
{
	sStateName = "BackAway",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nLow,
	nRadius = 8,
})

function BackAway:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe to events
	self.nTargetNotInProximityID = self:Subscribe (eEventType.AIE_TARGET_NOT_IN_PROXIMITY, self.tHost)

	self:OnResume ()
end

function BackAway:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	-- Set up proximity check
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nRadius)

	-- If Target is already far enough away just finish
	if self:IsTargetInProximity (self.nProximityCheckID) then

		-- Set the animation parameters for the brain state
		local tParams = self.tHost:RetBackAwayAnimationParams ()
	
		tParams:SetAnimID (eUpperBodyAnimationID.nBackOff)
		tParams:SetLoop (true)
	
		-- Set speed
		self.tHost:SetMovementType (self.nMovementType)
	
		-- Set priority
		self.tHost:SetMovementPriority (self.nMovementPriority)
	
		-- Use BackAway brain state
		self.tHost:BackAway ()

	else
		self:Finish ()
	end
end

function BackAway:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function BackAway:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function BackAway:OnEvent (tEvent)
	
	-- Target is now outside proximity radius
	if tEvent:HasID (self.nTargetNotInProximityID) and tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self:Finish ()
		return true

	end

	return TargetState.OnEvent (self, tEvent)
end
