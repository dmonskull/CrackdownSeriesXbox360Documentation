----------------------------------------------------------------------
-- Name: AttackCharacterUnarmed State
-- Description: Attack a character without weapons
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Combat\\MoveToAndCloseAttack"
require "State\\NPC\\Behaviour\\Combat\\UnarmedFightState"

AttackCharacterUnarmed = Create (UnarmedFightState, 
{
	sStateName = "AttackCharacterUnarmed",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nCombatTargetingChecks,
	nCircleDistance = 2.5,		-- Distance to circle at
	nMinCircleDistance = 1.5,	-- If the target moves this close move in to attack
	nMaxCircleDistance = 5,		-- If the target moves further away than this stop circling and run towards him
	bCanCircle = true,			-- Can I circle around the enemy between punches?
	bTargetEnteredVehicle = false,
})

function AttackCharacterUnarmed:OnEnter ()
	-- Determine time between strike attempts based on aggressiveness of personality
	if self.tHost:RetPersonality () >= ePersonality.nBrave then
		self.nStrikeTime = 2
	elseif self.tHost:RetPersonality () <= ePersonality.nCowardly then
		self.nStrikeTime = 6
	else
		self.nStrikeTime = 4
	end

	-- Call parent
	UnarmedFightState.OnEnter (self)

	-- Subscribe events
	self.nTargetEnteredVehicle = self:Subscribe (eEventType.AIE_TARGET_ENTERED_VEHICLE, self.tTargetInfo)
	self.nCombatTargetFoundID = self:Subscribe (eEventType.AIE_COMBAT_TARGET_FOUND, self.tTargetInfo)
	self.nDamagedID = self:SubscribeImmediate (eEventType.AIE_DAMAGE_TAKEN, self.tHost)

	-- Compelling dialogue... 
	self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "Let's discuss this rationally!", self.tTargetInfo:RetTarget ())
end

function AttackCharacterUnarmed:OnEvent (tEvent)

	-- Damaged somehow - get angry and attack
	if tEvent:HasID (self.nDamagedID) then

		if self:InCircleState () then
			self:ChangeState (self:CreateCloseAttackState ())
		end
		return true

	-- Target moved in range - take the opportunity to hit them
	elseif tEvent:HasID (self.nCombatTargetFoundID) then

		if self:InCircleState () then
			self:ChangeState (self:CreateCloseAttackState ())
		end
		return true

	-- Target is pretty close to me, so attack - note this is edge triggered, we only attack when
	-- the target MOVES close to us, not when the target IS close to us
	elseif tEvent:HasID (self.nTargetInProximityID) and tEvent:HasProximityCheckID (self.nMinProximityCheckID) then

		if self:InCircleState () then
			self:ChangeState (self:CreateCloseAttackState ())
		end
		return true

	elseif tEvent:HasID (self.nTargetEnteredVehicle) then

		self:EvaluateConditions ()
		return true

	end

	-- Call parent
	return UnarmedFightState.OnEvent (self, tEvent)
end

function AttackCharacterUnarmed:OnActiveStateFinished ()

	if self:InCloseAttackState () then

		self:ChangeState (self:CreateCircleState ())
		return true

	elseif self:InCircleState () then

		local nRand = cAIPlayer.Rand (1, 2)
		if nRand == 1 then
			self:ChangeState (self:CreateCloseAttackState ())
		elseif nRand == 2 then
			self:ChangeState (self:CreateInsultState ())
		end
		return true

	end

	-- Call parent
	return UnarmedFightState.OnActiveStateFinished (self)
end

function AttackCharacterUnarmed:EvaluateConditions ()

	if self.tTargetInfo:IsTargetInsideVehicle () then

		self.bTargetEnteredVehicle = true
		self:Finish ()
		return true

	-- Call parent
	elseif UnarmedFightState.EvaluateConditions (self) then

		return true

	elseif self:IsCloseAttackConditionSatisfied () then

		self:ChangeState (self:CreateCloseAttackState ())
		return true

	end

	-- Call parent
	return UnarmedFightState.EvaluateConditions (self)
end

function AttackCharacterUnarmed:IsCloseAttackConditionSatisfied ()

	-- Strike when the target's back is turned, or if circling is disabled
	if not self.tTargetInfo:IsTargetFacingMe () or
		not self.bCanCircle then

		if self:InCircleState () then
			return true
		end

	end
	return false

end

function AttackCharacterUnarmed:IsGetInProximityConditionSatisfied ()

	-- Has the target somehow gotten too far away from us as we are moving in to attack it?
	if not self:IsTargetInProximity (self.nMaxProximityCheckID) then

		if self:InCloseAttackState () then
			return true
		end

	end

	-- Call parent
	return UnarmedFightState.IsGetInProximityConditionSatisfied (self)
end

function AttackCharacterUnarmed:CreateCloseAttackState ()
	return Create (MoveToAndCloseAttack, 
	{
		nMovementType = eMovementType.nSprint,
		nReactionTime = cAIPlayer.FRand (0, 0.5),
	})
end

function AttackCharacterUnarmed:InCloseAttackState ()
	return self:IsInState (MoveToAndCloseAttack)
end

function AttackCharacterUnarmed:FirearmFound ()
	return self.bFirearmFound
end

function AttackCharacterUnarmed:TargetEnteredVehicle ()
	return self.bTargetEnteredVehicle
end
