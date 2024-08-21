----------------------------------------------------------------------
-- Name: Defender State
--	Description: A type of gangster that starts off like a patrolling guard, 
-- but when an event is triggered runs to a position and stays there, 
-- attacking anything that comes within range
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Guard"
require "State\\NPC\\Behaviour\\StandIdleAtSpawnPoint"

Defender = Create (Guard, 
{
	sStateName = "Defender",
	bDefensiveMode = true,
	nDefensiveRadius = 1,
})

function Defender:OnEnter ()
	-- If the spawn point is specified by name then get a pointer to it
	if self.sSpawnPointName then
		self.tSpawnPoint = cInfo.FindInfoByName (self.sSpawnPointName)
	end
	
--	assert (self.tSpawnPoint)

	-- Set up viewing distances for defensive mode (default to normal mode ones)
	self.nDefensiveIdleViewingDistance = self.nDefensiveIdleViewingDistance or self.nIdleViewingDistance
	self.nDefensiveAlertViewingDistance = self.nDefensiveAlertViewingDistance or self.nAlertViewingDistance

	-- Call parent
	Guard.OnEnter (self)

	-- Set properties
	if self.bDefensiveMode then
		self.tHost:SetGuardRadius (self.nDefensiveRadius)
		self.tHost:SetGuardPosition (self.tSpawnPoint:RetWalkPosition (self.tHost))
	end

	-- The defensive mode trigger is the object that generates the event telling the NPC to enter
	-- or exit defensive mode, by default this is the NPC itself
	self.tDefensiveModeTrigger = self.tDefensiveModeTrigger or self.tHost

	-- Subscribe events
	self.nDefensiveModeTriggerEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tDefensiveModeTrigger)
end

function Defender:OnEvent (tEvent)

	if tEvent:HasID (self.nDefensiveModeTriggerEventID) and tEvent:HasCustomEventID ("EnterDefensiveMode") then

		self:OnEnterDefensiveMode ()
		return true

	elseif tEvent:HasID (self.nDefensiveModeTriggerEventID) and tEvent:HasCustomEventID ("ExitDefensiveMode") then

		self:OnExitDefensiveMode ()
		return true

	end

	-- Call parent
	return Guard.OnEvent (self, tEvent)
end

function Defender:OnEnterDefensiveMode ()

	if not self.bDefensiveMode then

		-- Go into defensive mode
		self.bDefensiveMode = true
		self.tHost:SetGuardRadius (self.nDefensiveRadius)
		self.tHost:SetGuardPosition (self.tSpawnPoint:RetWalkPosition (self.tHost))

		-- Change state to use defensive mode
		if self:InIdleState () or
			self:InInvestigateState () or
			self:InAlertState () or
			self:InSearchState () or
			self:InGiveUpState () or
			self:InVictoryState () then

			-- If not actually in combat just stop everything and run to the spawn point
			self:ChangeState (self:CreateTransitionToIdleState ())

		elseif self:InAttackState () then

			-- If in combat then run to the spawn point while shooting
			local tState = self:RetActiveState ()
			self:ChangeState (self:CreateAttackState (tState.tTarget))

		end

	end

end

function Defender:OnExitDefensiveMode ()

	if self.bDefensiveMode then

		-- Go out of defensive mode
		self.bDefensiveMode = false
		self.tHost:SetGuardRadius (self.nRadius)
		self.tHost:SetGuardPosition (self.tHost:RetPosition ())

		-- Change state to stop using defensive mode
		if self:InIdleState () then

			-- Go back to patrolling
			self:ChangeState (self:CreateTransitionToIdleState ())

		elseif self:InAttackState () then

			-- Attack with new radius and defensive position
			local tState = self:RetActiveState ()
			self:ChangeState (self:CreateAttackState (tState.tTarget))

		end

	end

end

----------------------------------------------------------------------
-- Heard sounds of fighting
-- Over-ride base class to just ignore the sound - Defenders only care about
-- suspicious sounds
----------------------------------------------------------------------

function Defender:OnNPCHeardInterestingSound (tNPC, tSource)
end

----------------------------------------------------------------------
-- Idle State - Run to spawn point and stand idle there
----------------------------------------------------------------------

function Defender:CreateIdleState ()

	-- In defensive mode run to the spawn point and stay there
	if self.bDefensiveMode then
		return Create (StandIdleAtSpawnPoint, 
		{
			tSpawnPoint = self.tSpawnPoint,
			nMovementType = eMovementType.nRun,
		})
	end

	-- Call parent
	return Guard.CreateIdleState (self)
end

function Defender:InIdleState ()
	return Guard.InIdleState (self) or self:IsInState (StandIdleAtSpawnPoint)
end

----------------------------------------------------------------------
-- Investigate State
----------------------------------------------------------------------

function Defender:CreateInvestigateState (vPosition)

	-- In defensive mode only investigate within the defensive radius of the spawn point
	if self.bDefensiveMode then
		return Create (Investigate, 
		{
			vPosition = vPosition,
			vDefendedPosition = self.tSpawnPoint:RetWalkPosition (self.tHost),
			nRadius = self.nDefensiveRadius,
		})
	end

	-- Call parent
	return Guard.CreateInvestigateState (self, vPosition)
end

function Defender:InInvestigateState ()
	return Guard.InInvestigateState (self) or self:IsInState (Investigate)
end

----------------------------------------------------------------------
-- Alert State - Only take cover within the attention radius
----------------------------------------------------------------------

function Defender:CreateAlertState (tAttacker)

	-- In defensive mode only react within the defensive radius of the spawn point
	if self.bDefensiveMode then
		return Create (Alert, 
		{
			tAttacker = tAttacker,
			vDefendedPosition = self.tSpawnPoint:RetWalkPosition (self.tHost),
			nRadius = self.nDefensiveRadius,
		})
	end

	-- Call parent
	return Guard.CreateAlertState (self, tAttacker)
end

function Defender:InAlertState ()
	return Guard.InAlertState (self) or self:IsInState (Alert)
end

----------------------------------------------------------------------
-- Attack State - Move towards defended position and defend it
----------------------------------------------------------------------

function Defender:CreateAttackState (tTarget)

	-- In defensive mode run towards the spawn point first, then start fighting
	if self.bDefensiveMode then
		return Create (MoveAndCombat, 
		{
			tTarget = tTarget,
			vDestination = self.tSpawnPoint:RetWalkPosition (self.tHost),
			vDefendedPosition = self.tSpawnPoint:RetWalkPosition (self.tHost),
			nRadius = self.nDefensiveRadius,
		})
	end

	-- Call parent
	return Guard.CreateAttackState (self, tTarget)
end

function Defender:InAttackState ()
	return Guard.InAttackState (self) or self:IsInState (Combat)
end

----------------------------------------------------------------------
-- Search State - Defenders only search within their attention radius
----------------------------------------------------------------------

function Defender:CreateSearchState (tTarget, vStartingPosition, vViewPointPosition, vDirection)

	-- In defensive mode only search within the defensive radius of the spawn point
	if self.bDefensiveMode then
		return Create (Search, 
		{
			tTarget = tTarget,
			vDefendedPosition = self.tSpawnPoint:RetWalkPosition (self.tHost),
			nRadius = self.nDefensiveRadius,
			vStartingPosition = vStartingPosition,
			vViewPointPosition = vViewPointPosition,
			vDirection = vDirection,
		})
	end

	-- Call parent
	return Guard.CreateSearchState (self, tTarget, vStartingPosition, vViewPointPosition, vDirection)
end

function Defender:InSearchState ()
	return Guard.InSearchState (self) or self:IsInState (Search)
end

----------------------------------------------------------------------
-- Length of view cone
----------------------------------------------------------------------

function Defender:RetViewingDistance ()

	if self.bDefensiveMode then

		if self:InIdleState () or
			self:InTransitionToIdleState () or
			self:InWatchState () then
	
			return self.nDefensiveIdleViewingDistance
		else
			return self.nDefensiveAlertViewingDistance
		end

	end

	-- Call parent
	return Guard.RetViewingDistance (self)
end
