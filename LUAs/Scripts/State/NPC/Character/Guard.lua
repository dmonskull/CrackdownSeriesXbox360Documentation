----------------------------------------------------------------------
-- Name: Guard State
--	Description: A type of gangster that patrols along a set path and attacks 
-- anything suspicious within a specified attention radius
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Gangster"
require "State\\NPC\\Behaviour\\Patrol"
require "State\\NPC\\Behaviour\\Combat\\RaiseAlarmAndCombat"

Guard = Create (Gangster, 
{
	sStateName = "Guard",
	nIdleViewingDistance = 30,
	nRadius = 30,
})

function Guard:OnEnter ()
	-- Set Properties
	self.tHost:SetGuardRadius (self.nRadius)
	self.tHost:SetGuardPosition (self.tHost:RetPosition ())

	-- Listen for region change events so that we can if need be, 
	-- enter the patrol state on the correct region
	self.nChangeRegionEvent = self:Subscribe (eEventType.AIE_MISSIONDIST_CHANGE_REGION, self.tHost)

	-- Call parent
	Gangster.OnEnter (self)
end

function Guard:OnExit ()
	-- Call parent
	Gangster.OnExit (self)

	if self.tRegionChange then
		self:OnExitRegion ()
	end
end

function Guard:OnEvent (tEvent)

	-- If we are told to change regions, do so.
	if tEvent:HasID (self.nChangeRegionEvent) then
		Emit ("Guard " .. self.tHost:RetName() .. " has received a region change event")		
		if self.tRegionChange then
			self:OnExitRegion ()
		end
		if tEvent:RetRegion () then
			self:OnEnterRegion (tEvent:RetRegion ())
		end
		return true
	end

	-- Call parent
	return Gangster.OnEvent (self, tEvent)
end

function Guard:OnEnterRegion (tRegion)
	-- We store this in case we want to reenter the patrol state later
	self.tRegionChange = tRegion
end

function Guard:OnExitRegion ()
	self.tRegionChange = nil
end

----------------------------------------------------------------------
-- Heard sounds of fighting
-- Over-ride base class to just ignore the sound - Guards only care about
-- suspicious sounds
----------------------------------------------------------------------

function Guard:OnNPCHeardInterestingSound (tNPC, tSource)
end

----------------------------------------------------------------------
-- Idle State - Guards use Patrol as their 'idle' activity
----------------------------------------------------------------------

function Guard:CreateIdleState ()
	return Create (Patrol, 
	{
		tPatrolRouteNames = self.tPatrolRouteNames,
		tRegionChange = self.tRegionChange,
	})
end

function Guard:InIdleState ()
	return self:IsInState (Patrol)
end

----------------------------------------------------------------------
-- Investigate State - Only investigate within the attention radius
----------------------------------------------------------------------

function Guard:CreateInvestigateState (vPosition)
	return Create (Investigate, 
	{
		vPosition = vPosition,
		vDefendedPosition = self.tHost:RetGuardPosition (),
		nRadius = self.nRadius,
	})
end

function Guard:InInvestigateState ()
	return self:IsInState (Investigate)
end

----------------------------------------------------------------------
-- Alert State - Only take cover within the attention radius
----------------------------------------------------------------------

function Guard:CreateAlertState (tAttacker)
	return Create (Alert, 
	{
		tAttacker = tAttacker,
		vDefendedPosition = self.tHost:RetGuardPosition (),
		nRadius = self.nRadius,
	})
end

function Guard:InAlertState ()
	return self:IsInState (Alert)
end

----------------------------------------------------------------------
-- Attack State - Guards use defensive combat
----------------------------------------------------------------------

function Guard:CreateAttackState (tTarget)

	-- Raise the alarm before attacking, if it has not been raised already
	if self.tAttackSquadMission and not self.tAttackSquadMission:IsEnemyInList (tTarget) then

		return Create (RaiseAlarmAndCombat, 
		{
			tAttackSquadMission = self.tAttackSquadMission,
			tTarget = tTarget,
			vDefendedPosition = self.tHost:RetGuardPosition (),
			nRadius = self.nRadius,
		})

	else

		return Create (Combat, 
		{
			tTarget = tTarget,
			vDefendedPosition = self.tHost:RetGuardPosition (),
			nRadius = self.nRadius,
		})

	end

end

function Guard:InAttackState ()
	return self:IsInState (Combat)
end

----------------------------------------------------------------------
-- Search State - Guards only search within their attention radius
----------------------------------------------------------------------

function Guard:CreateSearchState (tTarget, vStartingPosition, vViewPointPosition, vDirection)
	return Create (Search, 
	{
		tTarget = tTarget,
		vDefendedPosition = self.tHost:RetGuardPosition (),
		nRadius = self.nRadius,
		vStartingPosition = vStartingPosition,
		vViewPointPosition = vViewPointPosition,
		vDirection = vDirection,
	})
end

function Guard:InSearchState ()
	return self:IsInState (Search)
end

----------------------------------------------------------------------
-- Victory State - clear alarm if it is raised
----------------------------------------------------------------------

function Guard:CreateVictoryState (tTarget)

	-- We don't need to send out squads after a dead guy
	if self.tAttackSquadMission and self.tAttackSquadMission:IsEnemyInList (tTarget) then
		self.tAttackSquadMission:RemoveEnemy (tTarget)
	end

	-- Call parent
	return Gangster.CreateVictoryState (self, tTarget)
end

----------------------------------------------------------------------
-- Map Status - Indicates what colour the NPC will be displayed on the map
----------------------------------------------------------------------

function Guard:RetMapStatus ()

	if self:InIdleState () then
		return eMapStatus.nPatrolling
	end

	-- Call parent
	return Gangster.RetMapStatus (self)
end
