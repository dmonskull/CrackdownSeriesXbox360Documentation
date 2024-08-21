----------------------------------------------------------------------
-- Name: StreetSoldier State
--	Description: A type of gangster that just wanders aimlessly until he is
-- attacked, at which point he attacks the attacker
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\PassiveGangster"
require "State\\NPC\\Behaviour\\Wander\\WanderEx"

StreetSoldier = Create (PassiveGangster, 
{
	sStateName = "StreetSoldier",
	bOnSideWalk = false,
})

----------------------------------------------------------------------
-- Bumped into someone while in the wander state
----------------------------------------------------------------------

function StreetSoldier:OnEncounter (tEntity)

	-- Is it someone I don't like?
	if not self.tHost:IsFriend (tEntity) and tEntity:IsAlive () then

		-- Get the gang manager
		local tGangManager = cGangManager.RetGangManager ()
		assert (tGangManager)

		local tGangInControl = tGangManager:RetGangInControl (self.tHost:RetPosition ())

		-- Push everyone around if my gang is in control
		if tGangInControl == self.tHost:RetTeamSide () then
			self:ChangeState (self:CreateStandoffState (tEntity))

		-- Be very polite if their gang is in control
		elseif tGangInControl == tEntity:RetTeamSide () then
			self:ChangeState (self:CreateApologiseState (tEntity))				

		-- If neither is in control, only attack if I am brave
		elseif self.tHost:RetPersonality () >= ePersonality.nBrave then
			self:ChangeState (self:CreateStandoffState (tEntity))

		end

	end

end

----------------------------------------------------------------------
-- Idle State - Streetsoldiers wander around as their 'idle' activity
----------------------------------------------------------------------

function StreetSoldier:CreateIdleState ()
	local tState = Create (WanderEx, 
	{
		bOnSideWalk = self.bOnSideWalk,
	})
	self.bOnSideWalk = false
	return tState
end

function StreetSoldier:InIdleState ()
	return self:IsInState (WanderEx)
end

----------------------------------------------------------------------
-- Global Graph tracking - indicates if the NPC should be considered an ambient
-- pedestrian and therefore managed by the population manager
----------------------------------------------------------------------

function StreetSoldier:IsGlobalGraphTracking ()

	if self:InIdleState () or
		self:InWatchState () or
		self:InApologiseState () or
		self:InStandoffState () or
		self:InTransitionToIdleState () then

		return true
	else
		return false
	end

end

----------------------------------------------------------------------
-- Return true if the StreetSoldier is available for use in ambient crimes
----------------------------------------------------------------------

function StreetSoldier:IsAvailable ()
	return self:InIdleState ()
end
