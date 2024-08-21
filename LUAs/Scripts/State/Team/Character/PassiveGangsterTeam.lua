----------------------------------------------------------------------
-- Name: PassiveGangsterTeam State
--	Description: A type of gangster team that does not attack on sight
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Team\\Character\\GangsterTeam"
require "State\\Team\\Behaviour\\TeamStandoff"
require "State\\Team\\Behaviour\\TeamApologise"

PassiveGangsterTeam = Create (GangsterTeam,
{
	sStateName = "PassiveGangsterTeam",
	nIdleViewingDistance = 4,
	nAnger = 0,
})

function PassiveGangsterTeam:OnEnter ()
	-- Call parent
	GangsterTeam.OnEnter (self)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)
end

function PassiveGangsterTeam:OnEnterTeamMember (tTeamMember)
	-- Call parent
	GangsterTeam.OnEnterTeamMember (self, tTeamMember)

	-- Subscribe events
	self.tTeamMembers[tTeamMember].nEntityAppearedID = self:Subscribe (eEventType.AIE_ENTITY_APPEARED, tTeamMember)
	self.tTeamMembers[tTeamMember].nTouchedID = self:Subscribe (eEventType.AIE_TOUCHED, tTeamMember)
end

function PassiveGangsterTeam:OnExitTeamMember (tTeamMember)
	-- Unsubscribe events
	self:Unsubscribe (self.tTeamMembers[tTeamMember].nEntityAppearedID)

	-- Call parent
	GangsterTeam.OnExitTeamMember (self, tTeamMember)
end

function PassiveGangsterTeam:OnEvent (tEvent)

	if self.nAngerTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nAngerTimerID) then
		
		-- Reset anger level since no one has bumped into us for a while
		self.nAnger = 0
		self.nAngerTimerID = nil
		return true

	end
	
	for tTeamMember, tTeamMemberEvents in pairs (self.tTeamMembers) do

		if tEvent:HasID (tTeamMemberEvents.nEntityAppearedID) then

			if self:InPreEncounterState () then
				self:OnEncounter (tTeamMember, tEvent:RetEntity ())
			end
			return true
		
		elseif tEvent:HasID (tTeamMemberEvents.nTouchedID) then

			local tToucher = tEvent:RetToucher ()
			if self:InPreEncounterState () and tTeamMember:IsInViewCone (tToucher:RetEyePosition ()) then
				self:OnEncounter (tTeamMember, tToucher)
			end
			return true

		end

	end

	-- Call parent
	return GangsterTeam.OnEvent (self, tEvent)
end


function PassiveGangsterTeam:OnActiveStateFinished ()
	
	if self:InStandoffState () then

		local tState = self:RetActiveState ()
		if tState:Escalate () then

			-- Escalate to Attack State
			self.tHost:AddEnemy (tState.tTarget, eEnemyStatus.nActive)
			self:ChangeState (self:CreateAttackState ())
		
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
	return GangsterTeam.OnActiveStateFinished (self)
end

----------------------------------------------------------------------
-- Bumped into someone while in the idle state
----------------------------------------------------------------------

function PassiveGangsterTeam:OnEncounter (tTeamMember, tEntity)
end

----------------------------------------------------------------------
-- Detected an enemy
-- Over-ride base class to ignore the enemy (PassiveGangsters don't attack on sight)
----------------------------------------------------------------------

function PassiveGangsterTeam:OnNPCDetectedEnemy (tNPC, tEnemy)
end

----------------------------------------------------------------------
-- Heard a suspicious sound
-- Over-ride base class to just ignore the sound
----------------------------------------------------------------------

function PassiveGangsterTeam:OnNPCHeardSuspiciousSound (tNPC, vPosition)
end

----------------------------------------------------------------------
-- Standoff State
----------------------------------------------------------------------

function PassiveGangsterTeam:CreateStandoffState (tTeamMember, tTarget)
	return Create (TeamStandoff, 
	{
		tTeamMember = tTeamMember,
		tTarget = tTarget,
		nAnger = self.nAnger,
	})
end

function PassiveGangsterTeam:InStandoffState ()
	return self:IsInState (TeamStandoff)
end

----------------------------------------------------------------------
-- Apologise State
----------------------------------------------------------------------

function PassiveGangsterTeam:CreateApologiseState (tTeamMember, tTarget)
	return Create (TeamApologise, 
	{
		tTeamMember = tTeamMember,
		tTarget = tTarget,
	})
end

function PassiveGangsterTeam:InApologiseState ()
	return self:IsInState (TeamApologise)
end

----------------------------------------------------------------------
-- Return true if we can break out of the current state to enter a new one
-- Over-ride base class to include Standoff and Apologise states
----------------------------------------------------------------------

function PassiveGangsterTeam:InPreEncounterState ()
	return self:InIdleState ()
end

function PassiveGangsterTeam:InPreAlertState ()
	return Gangster.InPreAlertState (self) or
		self:InStandoffState () or
		self:InApologiseState ()
end

function PassiveGangsterTeam:InPreAttackState ()
	return Gangster.InPreAttackState (self) or
		self:InStandoffState () or
		self:InApologiseState ()
end

function PassiveGangsterTeam:InPreFleeState ()
	return Gangster.InPreFleeState (self) or
		self:InStandoffState () or
		self:InApologiseState ()
end
