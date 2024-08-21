----------------------------------------------------------------------
-- Name: StayInProximity State
--	Description: Stay within a specified radius of the target, and face the target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Chase\\Chase"

StayInProximity = Create (TargetState,
{
	sStateName = "StayInProximity",
	nMovementType = eMovementType.nRun,
	nMovementPriority = eMovementPriority.nLow,
	tStopState = Face,
	tMoveState = Chase,
	nMinDist = 10,
	nMaxDist = 15,
})

function StayInProximity:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self.nMinProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nMinDist)
	self.nMaxProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nMaxDist)

	-- Subscribe to events
	self.nTargetInProximityID = self:Subscribe (eEventType.AIE_TARGET_IN_PROXIMITY, self.tHost)	
	self.nTargetNotInProximityID = self:Subscribe (eEventType.AIE_TARGET_NOT_IN_PROXIMITY, self.tHost)	

	-- Face target
	self:PushState (Create (self.tStopState, {}))

	self:OnResume ()
end

function StayInProximity:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

	self:EvaluateConditions ()
end

function StayInProximity:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetInProximityID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nTargetNotInProximityID) then
	
		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function StayInProximity:EvaluateConditions ()

	local tState = self:RetActiveState ()

	if self:IsTargetInProximity (self.nMinProximityCheckID) then

		-- Target is within the minimum proximity radius - just stand and face the target
		if self:IsInState (self.tMoveState) then
			self:PopState ()
		end

	elseif not self:IsTargetInProximity (self.nMaxProximityCheckID) then
	
		-- Target is outside of the maximum proximity radius - chase the target
		if self:IsInState (self.tStopState) then
			self:PushState (Create (self.tMoveState, 
			{
				nMovementType = self.nMovementType,
				nMovementPriority = self.nMovementPriority,
			}))
		end

	end

end
