----------------------------------------------------------------------
-- Name: BodyGuard State
--	Description: A type of gangster that follows a boss and attacks 
-- anything suspicious within a specified attention radius of the boss
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Gangster"
require "State\\NPC\\Action\\Follow\\Follow"

BodyGuard = Create (Gangster, 
{
	sStateName = "BodyGuard",
	nRadius = 30,
})

function BodyGuard:OnEnter ()
	-- Check parameters
	assert (self.tDefendedObject)

	-- Set Properties
	self.tHost:SetGuardRadius (self.nRadius)
	self.tHost:SetGuardObject (self.tDefendedObject)

	-- Call parent
	Gangster.OnEnter (self)
end

----------------------------------------------------------------------
-- Heard sounds of fighting
-- Over-ride base class to just ignore the sound - BodyGuards only care about
-- suspicious sounds
----------------------------------------------------------------------

function BodyGuard:OnNPCHeardInterestingSound (tNPC, tSource)
end

----------------------------------------------------------------------
-- Idle State - Temporary! - Follow the boss
----------------------------------------------------------------------

function BodyGuard:CreateIdleState ()
	return Create (Follow, 
	{
		tTarget = self.tDefendedObject,
	})
end

function BodyGuard:InIdleState ()
	return self:IsInState (Follow)
end

----------------------------------------------------------------------
-- Investigate State - Only investigate within the attention radius
----------------------------------------------------------------------

function BodyGuard:CreateInvestigateState (vPosition)
	return Create (Investigate, 
	{
		vPosition = vPosition,
		tDefendedObject = self.tDefendedObject,
		nRadius = self.nRadius,
	})
end

function BodyGuard:InInvestigateState ()
	return self:IsInState (Investigate)
end

----------------------------------------------------------------------
-- Alert State - Only take cover within the attention radius
----------------------------------------------------------------------

function BodyGuard:CreateAlertState (tAttacker)
	return Create (Alert, 
	{
		tAttacker = tAttacker,
		tDefendedObject = self.tDefendedObject,
		nRadius = self.nRadius,
	})
end

function BodyGuard:InAlertState ()
	return self:IsInState (Alert)
end

----------------------------------------------------------------------
-- Attack State - Guards use defensive combat
----------------------------------------------------------------------

function BodyGuard:CreateAttackState (tTarget)
	return Create (Combat, 
	{
		tTarget = tTarget,
		tDefendedObject = self.tDefendedObject,
		nRadius = self.nRadius,
	})
end

function BodyGuard:InAttackState ()
	return self:IsInState (Combat)
end

----------------------------------------------------------------------
-- Search State - Guards only search within their attention radius
----------------------------------------------------------------------

function BodyGuard:CreateSearchState (tTarget, vStartingPosition, vViewPointPosition, vDirection)
	return Create (Search, 
	{
		tTarget = tTarget,
		tDefendedObject = self.tDefendedObject,
		nRadius = self.nRadius,
		vStartingPosition = vStartingPosition,
		vViewPointPosition = vViewPointPosition,
		vDirection = vDirection,
	})
end

function BodyGuard:InSearchState ()
	return self:IsInState (Search)
end
