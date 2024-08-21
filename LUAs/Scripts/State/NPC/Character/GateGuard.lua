----------------------------------------------------------------------
-- Name: GateGuard State
--	Description: A type of gangster that patrols along a set path (which
-- typically will have just one or two nodes) and attacks anyone who enters
-- a specified trigger zone)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Guard"
require "State\\NPC\\Behaviour\\Scripted\\Warn"
require "State\\NPC\\Behaviour\\Listen\\WaitAndListen"

GateGuard = Create (Guard, 
{
	sStateName = "GateGuard",
	nIdleViewingDistance = 5,
})

function GateGuard:OnEnter ()
	-- Check parameters
	assert (self.sTriggerZoneName)

	-- Get trigger zone
	self.tTriggerZone = self:RetTriggerZone (self.sTriggerZoneName)
	assert (self.tTriggerZone)

	-- Listen for region change events so that we can if need be, 
	-- enter the patrol state on the correct region
	self.nZoneAIPlayerID = self:Subscribe (eEventType.AIE_ZONE_AIPLAYER, self.tTriggerZone)
	self.nZonePlayerID = self:Subscribe (eEventType.AIE_ZONE_PLAYER, self.tTriggerZone)

	-- Call parent
	Guard.OnEnter (self)
end

function GateGuard:OnEvent (tEvent)

	if tEvent:HasID (self.nZoneAIPlayerID) or
		tEvent:HasID (self.nZonePlayerID) then

		-- Someone entered my trigger zone!
		if tEvent:IsEntering () then

			-- Attack them!
			if self:IsAttackConditionSatisfied (tEvent:RetInstigator ()) then

				self:ChangeState (self:CreateAttackState (tEvent:RetInstigator ()))

			end

		end
		return true

	end

	-- Call parent
	return Guard.OnEvent (self, tEvent)
end

function GateGuard:OnActiveStateFinished ()
	
	if self:InWarnState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	end

	-- Call Parent
	return Guard.OnActiveStateFinished (self)
end

----------------------------------------------------------------------
-- Detected an enemy
----------------------------------------------------------------------

function GateGuard:OnNPCDetectedEnemy (tNPC, tEnemy)

	if self:IsWarnConditionSatisfied (tEnemy) then

		self:ChangeState (self:CreateWarnState (tEnemy))

	else

		-- Call parent
		Guard.OnNPCDetectedEnemy (self, tNPC, tEnemy)

	end

end

----------------------------------------------------------------------
-- Heard sounds of fighting
----------------------------------------------------------------------

function GateGuard:OnNPCHeardInterestingSound (tNPC, tSource)

	if self:IsWatchConditionSatisfied (tSource) then

		-- Watch the exciting things that are happening
		self:ChangeState (self:CreateWatchState (tSource))

	end

end

----------------------------------------------------------------------
-- Will attack if enemy is visible and in trigger zone
----------------------------------------------------------------------

function GateGuard:IsAttackConditionSatisfied (tEnemy)

	-- Call parent
	if Guard.IsAttackConditionSatisfied (self, tEnemy) then

		if	tEnemy:IsAlive () and
			self.tHost:IsEnemy (tEnemy) and
			self.tHost:IsVisible (tEnemy) and
			self.tTriggerZone:IsInTriggerZone (tEnemy) then

			return true
		
		end

	end
	return false

end

----------------------------------------------------------------------
-- Will warn if enemy is outside trigger zone
----------------------------------------------------------------------

function GateGuard:IsWarnConditionSatisfied (tEnemy)

	if not self:IsActiveStateLocked () then

		if self:InPreWarnState () then

			if tEnemy:IsAlive () and
				self.tHost:IsEnemy (tEnemy) and
				self.tHost:IsVisible (tEnemy) and
				not self.tTriggerZone:IsInTriggerZone (tEnemy) then
		
				return true
		
			end

		end

	end
	return false

end

----------------------------------------------------------------------
-- Watch State - Watch but don't follow the target
----------------------------------------------------------------------

function GateGuard:CreateWatchState (tSource)
	return Create (TimedWatch, 
	{
		tEntity = tSource,
		bFollow = false,
	})
end

function GateGuard:InWatchState ()
	return self:IsInState (TimedWatch)
end

----------------------------------------------------------------------
-- Investigate State - Just face the source of the noise for a few seconds,
-- don't walk towards it
----------------------------------------------------------------------

function GateGuard:CreateInvestigateState (vPosition)
	return Create (WaitAndListen, 
	{
		vPosition = vPosition,
		nWaitTime = 5,
	})
end

function GateGuard:InInvestigateState ()
	return self:IsInState (WaitAndListen)
end

----------------------------------------------------------------------
-- Warn State
----------------------------------------------------------------------

function GateGuard:CreateWarnState (tTarget)
	return Create (Warn, 
	{
		tTarget = tTarget,
	})
end

function GateGuard:InWarnState ()
	return self:IsInState (Warn)
end

function GateGuard:InPreWarnState ()
	return self:InIdleState () or
		self:InInvestigateState () or
		self:InWatchState ()
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
-- Over-ride base class to include warn state
----------------------------------------------------------------------

function GateGuard:InPreAlertState ()
	return Guard.InPreAlertState (self) or self:InWarnState ()
end

function GateGuard:InPreAttackState ()
	return Guard.InPreAttackState (self) or self:InWarnState ()
end

function GateGuard:InPreFleeState ()
	return Guard.InPreFleeState (self) or self:InWarnState ()
end
