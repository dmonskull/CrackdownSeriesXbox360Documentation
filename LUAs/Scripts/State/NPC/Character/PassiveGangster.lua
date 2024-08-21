----------------------------------------------------------------------
-- Name: PassiveGangster State
--	Description: A type of gangster that does not attack on sight
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Gangster"
require "State\\NPC\\Behaviour\\Scripted\\Standoff"
require "State\\NPC\\Behaviour\\Scripted\\Apologise"

PassiveGangster = Create (Gangster, 
{
	sStateName = "PassiveGangster",
	nIdleViewingDistance = 4,
	nAnger = 0,
})

----------------------------------------------------------------------
-- OnEnter
----------------------------------------------------------------------

function PassiveGangster:OnEnter ()
	-- Save the current viewing distance
	self.nViewingDistance = self.nViewingDistance or self.tHost:RetViewingDistance ()

	-- Call parent
	Gangster.OnEnter (self)	

	-- Subscribe to events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
	self.nEntityAppearedID = self:Subscribe (eEventType.AIE_ENTITY_APPEARED, self.tHost)
	self.nTouchedID = self:Subscribe (eEventType.AIE_TOUCHED, self.tHost)
end

function PassiveGangster:OnEvent (tEvent)

	local tState = self:RetActiveState ()

	if self.nAngerTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nAngerTimerID) then
		
		-- Reset anger level since no one has bumped into me for a while
		self.nAnger = 0
		self.nAngerTimerID = nil
		return true

	elseif tEvent:HasID (self.nEntityAppearedID) then

		if self:InPreEncounterState () then
			self:OnEncounter (tEvent:RetEntity ())
		end
		return true

	elseif tEvent:HasID (self.nTouchedID) then

		local tToucher = tEvent:RetToucher ()
		if self:InPreEncounterState () and self.tHost:IsInViewCone (tToucher:RetEyePosition ()) then
			self:OnEncounter (tToucher)
		end
		return true

	end

	-- Call parent
	return Gangster.OnEvent(self, tEvent)
end

function PassiveGangster:OnActiveStateFinished ()
	
	if self:InAttackState () then

		local tState = self:RetActiveState ()
		if tState:TargetLost () then

			-- Target was lost - search for them
			self:ChangeState (self:CreateSearchState (tState.tTarget, tState.vLastTargetPosition, tState.vLastTargetViewPointPosition, tState.vLastTargetVelocity))

		elseif tState:TargetDied () then

			-- Target was killed - victory
			self:ChangeState (self:CreateVictoryState (tState.tTarget))

		elseif tState:TargetDeleted () then

			-- Target was deleted
			self:ChangeState (self:CreateTransitionToIdleState ())

		end
		return true

	elseif self:InStandoffState () then

		local tState = self:RetActiveState ()
		if tState:Escalate () then

			-- Escalate to Attack State
			self:ChangeState (self:CreateAttackState (tState.tTarget))
		
		else
		
			-- Stand down, but remain angry for a while
			self.nAnger = tState.nAnger
			self.nAngerTimerID = self:AddTimer (20, false)
			self:ChangeState (self:CreateTransitionToIdleState ())

		end
		return true

	elseif self:InApologiseState () then

		self:ChangeState (self:CreateTransitionToIdleState ())
		return true

	end

	-- Call Parent
	return Gangster.OnActiveStateFinished (self)
end

function PassiveGangster:OnActiveStateUnlocked ()

	if self:InAlertState () then
	
		-- Over-ride the base here as we don't attack enemies on sight
		return true

	end
	
	-- Call parent
	return Gangster.OnActiveStateUnlocked (self)
end

----------------------------------------------------------------------
-- Bumped into someone while in the idle state
----------------------------------------------------------------------

function PassiveGangster:OnEncounter (tEntity)
end

----------------------------------------------------------------------
-- Detected an enemy
-- Over-ride base class to ignore the enemy (PassiveGangsters don't attack on sight)
----------------------------------------------------------------------

function PassiveGangster:OnNPCDetectedEnemy (tNPC, tEnemy)
end

----------------------------------------------------------------------
-- Heard a suspicious sound
-- Over-ride base class to just ignore the sound
----------------------------------------------------------------------

function PassiveGangster:OnNPCHeardSuspiciousSound (tNPC, vPosition)
end

----------------------------------------------------------------------
-- Standoff State
----------------------------------------------------------------------

function PassiveGangster:CreateStandoffState (tTarget)
	return Create (Standoff, 
	{
		tTarget = tTarget,
		nAnger = self.nAnger,
	})
end

function PassiveGangster:InStandoffState ()
	return self:IsInState (Standoff)
end

----------------------------------------------------------------------
-- Apologise State
----------------------------------------------------------------------

function PassiveGangster:CreateApologiseState (tTarget)
	return Create (Apologise, 
	{
		tTarget = tTarget,
	})
end

function PassiveGangster:InApologiseState ()
	return self:IsInState (Apologise)
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
-- Over-ride base class to include Standoff and Apologise states
----------------------------------------------------------------------

function PassiveGangster:InPreEncounterState ()
	return self:InIdleState ()
end

function PassiveGangster:InPreAlertState ()
	return Gangster.InPreAlertState (self) or
		self:InStandoffState () or
		self:InApologiseState ()
end

function PassiveGangster:InPreAttackState ()
	return Gangster.InPreAttackState (self) or
		self:InStandoffState () or
		self:InApologiseState ()
end

function PassiveGangster:InPreFleeState ()
	return Gangster.InPreFleeState (self) or
		self:InStandoffState () or
		self:InApologiseState ()
end
