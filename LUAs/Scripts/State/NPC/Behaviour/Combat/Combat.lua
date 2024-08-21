----------------------------------------------------------------------
-- Name: Combat State
-- Description: A big uber-combat state that encapsulates all the different
-- combat styles and decides which one to use, and handles things like
-- grenade reactions that apply to all combat states
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Behaviour\\Arm\\ArmWithBestWeapon"
require "State\\NPC\\Behaviour\\Combat\\AttackCharacterArmed"
require "State\\NPC\\Behaviour\\Combat\\AttackCharacterUnarmed"
require "State\\NPC\\Behaviour\\Combat\\AttackVehicleArmed"
require "State\\NPC\\Behaviour\\Combat\\AttackVehicleUnarmed"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeReaction"
require "State\\NPC\\Behaviour\\PropReaction\\PropReaction"
require "State\\NPC\\Behaviour\\WoundedReaction\\WoundedReaction"

Combat = Create (TargetState,
{
	sStateName = "Combat",
	bCanTakeCover = true,		-- Can I take cover when under fire?
	bCanGrenadeAttack = true,	-- Can I throw grenades?
	bCanPropAttack = true,		-- Can I throw props at the enemy?
	bCanFirearmAttack = true,	-- Can I use firearms?
	bCanCircle = true,			-- Can I circle around the enemy between punches when in a fistfight?
	bTargetLost = false,
	bTargetDied = false,
})

function Combat:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe events
	self.nGrenadeSoundID = self:SubscribeImmediate (eEventType.AIE_GRENADE_SOUND, self.tHost)
	self.nGrenadeVocalID = self:SubscribeImmediate (eEventType.AIE_GRENADE_VOCAL, self.tHost)
	self.nTouchedGrenadeID = self:SubscribeImmediate (eEventType.AIE_TOUCHED_GRENADE, self.tHost)
	self.nObjectApproachingID = self:SubscribeImmediate (eEventType.AIE_OBJECT_APPROACHING, self.tHost)
	self.nShotInLegID = self:SubscribeImmediate (eEventType.AIE_SHOT_IN_LEG, self.tHost)
	self.nDamagedID = self:SubscribeImmediate (eEventType.AIE_DAMAGE_TAKEN, self.tHost)
	self.nTargetDiedID = self:Subscribe (eEventType.AIE_TARGET_DIED, self.tTargetInfo)

	-- Pull out a gun if we have one
	self:PushState (Create (ArmWithBestWeapon, 
	{
		bCanFirearmAttack = self.bCanFirearmAttack,
	}))

	-- Evaluate conditions
	self:EvaluateConditions ()
end

function Combat:OnResume ()
	-- Call parent
	TargetState.OnResume (self)
	
	-- Evaluate conditions
	self:EvaluateConditions ()
end

function Combat:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (ArmWithBestWeapon) then

		self:ChangeState (self:CreateFightState ())
		return true

	elseif tState:IsA (FightState) then

		if tState:TargetLost () then

			self.bTargetLost = true
			self.vLastTargetPosition = self.tTargetInfo:RetLastTargetPosition ()
			self.vLastTargetViewPointPosition = self.tTargetInfo:RetLastTargetViewPointPosition ()
			self.vLastTargetVelocity = self.tTargetInfo:RetLastTargetVelocity ()
			self:Finish ()

		else

			self:ChangeState (self:CreateFightState ())

		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function Combat:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetDiedID) then

		self:EvaluateConditions ()
		return true

	elseif tEvent:HasID (self.nDamagedID) then

		self:OnDamaged (tEvent:RetInstigator ())
		return true

	elseif tEvent:HasID (self.nTouchedGrenadeID) then

		self:OnDetectedGrenade (tEvent:RetGrenade ())
		return true

	elseif tEvent:HasID (self.nGrenadeSoundID) then

		self:OnDetectedGrenade (tEvent:RetSource ())
		return true

	elseif tEvent:HasID (self.nGrenadeVocalID) then

		self:OnDetectedGrenade (tEvent:RetGrenade ())
		return true

	elseif tEvent:HasID (self.nObjectApproachingID) then

		self:OnObjectApproaching (tEvent:RetObject (), tEvent:RetInstigator ())
		return true

	elseif tEvent:HasID (self.nShotInLegID) then

--		self:OnWounded (tEvent:RetAttacker ())
		return true

	end	
	
	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Combat:EvaluateConditions ()

	-- Target is dead so finish
	if not self.tTargetInfo:IsTargetAlive () then

		self.bTargetDied = true
		self.vLastTargetPosition = self.tTargetInfo:RetLastTargetPosition ()
		self.vLastTargetViewPointPosition = self.tTargetInfo:RetLastTargetViewPointPosition ()
		self.vLastTargetVelocity = self.tTargetInfo:RetLastTargetVelocity ()
		self:Finish ()
		return true

	end
	return false

end

function Combat:OnDamaged (tInstigator)

	if tInstigator and not self:IsFriendlyFire (self.tHost, tInstigator) then

		-- Magically know where the target is if he shoots me
		if AILib.IsSameObject (self.tTargetInfo:RetTarget (), tInstigator) then
			self.tTargetInfo:Reveal ()
		end

		-- Shout in pain
		self.tHost:ShoutPainAudio (eVocals.nPain, "Aargh!", tInstigator)

	end

end

function Combat:OnDetectedGrenade (tGrenade)

	if not self:IsInState (GrenadeReaction) and 
		not self:IsInState (PropReaction) and 
		not self:IsInState (WoundedReaction) then

		if self:IsGrenadeAThreat (self.tHost, tGrenade) then

			self:PushState (Create (GrenadeReaction, 
			{
				tTarget = tGrenade,
			}))

		end

	end

end

function Combat:OnObjectApproaching (tObject, tInstigator)

	if not self:IsInState (GrenadeReaction) and 
		not self:IsInState (PropReaction) and 
		not self:IsInState (WoundedReaction) then

		if tObject and tInstigator and not self:IsFriendlyFire (self.tHost, tInstigator) then

			self:PushState (Create (PropReaction, 
			{
				tTarget = tObject,
			}))

		end

	end	

end

function Combat:OnWounded (tAttacker)

	if not self:IsInState (GrenadeReaction) and 
		not self:IsInState (PropReaction) and 
		not self:IsInState (WoundedReaction) then

		self:PushState (Create (WoundedReaction, 
		{
			tTarget = tAttacker,
		}))

	end

end

function Combat:CreateFightState ()

	-- Is the target in a vehicle?
	if self.tTargetInfo:IsTargetInsideVehicle () then

		-- Yes, go into one of the anti vehicle modes
		if self.tHost:IsCurrentPrimaryEquipmentEquiped () then

			return Create (AttackVehicleArmed, 
			{
				vDefendedPosition = self.vDefendedPosition,
				tDefendedObject = self.tDefendedObject,
				nRadius = self.nRadius,
				bCanGrenadeAttack = self.bCanGrenadeAttack,
				bCanTakeCover = self.bCanTakeCover,
			})

		else

			return Create (AttackVehicleUnarmed, 
			{
				bCanPropAttack = self.bCanPropAttack,
				bCanFirearmAttack = self.bCanFirearmAttack,
			})

		end

	else

		-- Do we have a gun?
		if self.tHost:IsCurrentPrimaryEquipmentEquiped () then

			return Create (AttackCharacterArmed, 
			{
				vDefendedPosition = self.vDefendedPosition,
				tDefendedObject = self.tDefendedObject,
				nRadius = self.nRadius,
				bCanGrenadeAttack = self.bCanGrenadeAttack,
				bCanTakeCover = self.bCanTakeCover,
			})

		else

			return Create (AttackCharacterUnarmed, 
			{
				bCanPropAttack = self.bCanPropAttack,
				bCanFirearmAttack = self.bCanFirearmAttack,
				bCanCircle = self.bCanCircle,
			})

		end

	end

end

function Combat:IsLocked ()
	return self:IsInState (GrenadeReaction) or 
		self:IsInState (PropReaction) or 
		self:IsInState (WoundedReaction)
end

function Combat:TargetLost ()
	return self.bTargetLost
end

function Combat:TargetDied ()
	return self.bTargetDied
end
