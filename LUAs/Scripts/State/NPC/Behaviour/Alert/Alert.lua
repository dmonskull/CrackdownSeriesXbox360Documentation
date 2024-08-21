----------------------------------------------------------------------
-- Name: Alert State
--	Description: Turn round to see who shot me
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Idle\\Wait"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Movement\\MoveAndFace"
require "State\\NPC\\Behaviour\\Arm\\Arm"
require "State\\NPC\\Behaviour\\Listen\\WaitAndListen"
require "State\\NPC\\Behaviour\\Alert\\AlertTraversal"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeReaction"
require "State\\NPC\\Behaviour\\PropReaction\\PropReaction"
require "State\\NPC\\Behaviour\\WoundedReaction\\WoundedReaction"

Alert = Create (State, 
{
	sStateName = "Alert",
	bAttackerFound = false,
	nNumAttackers = 0,
})

FaceAttackDirection = Create (Turn,
{
	sStateName = "FaceAttackDirection",
})

WatchAttackDirection = Create (Wait,
{
	sStateName = "WatchAttackDirection",
	nWaitTime = 1,
})

AlertRunToCover = Create (Move,
{
	sStateName = "AlertRunToCover",
	nMovementType = eMovementType.nRun,	
})

WaitInCover = Create (WaitAndListen,
{
	sStateName = "WaitInCover",
})

LeaveCover = Create (MoveAndFace,
{
	sStateName = "LeaveCover",
	nMovementType = eMovementType.nWalk,	
})

function Alert:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tAttacker)

	-- Determine time spent taking cover, based on personality
	if self.tHost:RetPersonality () >= ePersonality.nBrave then
		self.nWaitInCoverTime = 5
	elseif self.tHost:RetPersonality () > ePersonality.nCowardly then
		self.nWaitInCoverTime = 15
	else
		self.nWaitInCoverTime = 30
	end

	-- Create attack positions table
	self.tAttackerPositions = {}

	if self:AddAttacker (self.tAttacker) then

		-- Turn to face the direction of the attack
		self:PushState (Create (FaceAttackDirection,
		{
			vTargetPosition = self.tAttackerPositions [self.tAttacker],
		}))

		-- Subscribe events
		self.nEntityAppearedID = self:Subscribe (eEventType.AIE_ENTITY_APPEARED, self.tHost)
		self.nDamagedID = self:SubscribeImmediate (eEventType.AIE_DAMAGE_TAKEN, self.tHost)
		self.nPainVocalID = self:SubscribeImmediate (eEventType.AIE_PAIN_VOCAL, self.tHost)
		self.nGrenadeSoundID = self:SubscribeImmediate (eEventType.AIE_GRENADE_SOUND, self.tHost)
		self.nGrenadeVocalID = self:SubscribeImmediate (eEventType.AIE_GRENADE_VOCAL, self.tHost)
		self.nTouchedGrenadeID = self:SubscribeImmediate (eEventType.AIE_TOUCHED_GRENADE, self.tHost)
		self.nObjectApproachingID = self:SubscribeImmediate (eEventType.AIE_OBJECT_APPROACHING, self.tHost)
		self.nShotInLegID = self:SubscribeImmediate (eEventType.AIE_SHOT_IN_LEG, self.tHost)

	end

end

function Alert:OnEvent (tEvent)

	if tEvent:HasID (self.nEntityAppearedID) then

		-- We found the attacker
		local tAttacker = tEvent:RetEntity ()
		if self.tAttackerPositions [tAttacker] then
			self.tAttacker = tAttacker
			self.bAttackerFound = true
			self:Finish ()
		end
		return true
	
	elseif tEvent:HasID (self.nDamagedID) then
	
		self:OnDamaged (tEvent:RetInstigator ())
		return true

	elseif tEvent:HasID (self.nPainVocalID) then

		-- Is the person doing the shouting a friend?
		if self.tHost:IsFriend (tEvent:RetSource ()) then
			self:OnAttacked (tEvent:RetAttacker ())
		end
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
	return State.OnEvent (self, tEvent)
end

function Alert:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (FaceAttackDirection) then

		-- Pull out a gun if we have one
		self:ChangeState (Create (Arm, {}))
		return true

	elseif tState:IsA (Arm) then

		-- Wait for a short while facing the direction of the attack
		self:ChangeState (Create (WatchAttackDirection, {}))
		return true

	elseif tState:IsA (WatchAttackDirection) then

		-- Find somewhere to take cover
		self:ChangeState (Create (AlertTraversal, 
		{
			nNumAttackers = self.nNumAttackers,
			tAttackerPositions = self.tAttackerPositions,
			tDefendedObject = self.tDefendedObject,
			vDefendedPosition = self.vDefendedPosition,
			nRadius = self.nRadius,
		}))
		return true

	elseif tState:IsA (AlertTraversal) then

		if tState:Success () then
			-- Store the cover position
			self.vCoverPosition = tState.vCoverPosition,

			-- Run to the cover position
			self:ChangeState (Create (AlertRunToCover,		
			{
				vDestination = tState.vCoverPosition,
			}))
		else
			-- Fail
			self.vCoverPosition = self.tHost:RetEyePosition ()
			self.bAttackerFound = false
			self:Finish ()
		end
		return true

	elseif tState:IsA (AlertRunToCover) then

		-- Wait in cover
		self:ChangeState (Create (WaitInCover,
		{
			vPosition = self.vOriginalPosition,
			nWaitTime = self.nWaitInCoverTime,
		}))
		return true

	elseif tState:IsA (WaitInCover) then

		-- Walk out of cover, looking in the direction of the last attacker
		self:ChangeState (Create (LeaveCover,
		{
			vDestination = self.vOriginalPosition,
			vTargetPosition = self.tAttackerPositions [self.tAttacker],
		}))
		return true

	elseif tState:IsA (LeaveCover) then

		-- Can't see the attacker
		self.bAttackerFound = false
		self:Finish ()
		return true

	elseif tState:IsA (GrenadeReaction) or 
			tState:IsA (PropReaction) or 
			tState:IsA (WoundedReaction) then

		-- Pop the state
		self:PopState ()

		-- Check if any of the attackers are now visible
		for tAttacker in pairs (self.tAttackerPositions) do
			if self.tHost:IsVisible (tAttacker) then
				self.bAttackerFound = true
				self:Finish ()
			end
		end
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

function Alert:OnDamaged (tInstigator)

	-- Shout in pain to warn friends that I am under attack
	if tInstigator and not self:IsFriendlyFire (self.tHost, tInstigator) then

		self.tHost:ShoutPainAudio (eVocals.nPain, "I'm under attack!", tInstigator)
		self:OnAttacked (tInstigator)

	end

end

function Alert:OnDetectedGrenade (tGrenade)

	if self:IsGrenadeAThreat (self.tHost, tGrenade) then

		if self:AddAttacker (tGrenade:RetActivator ()) then
	
			if not self:IsInState (GrenadeReaction) and 
				not self:IsInState (PropReaction) and 
				not self:IsInState (WoundedReaction) then
	
				self:PushState (Create (GrenadeReaction, 
				{
					tTarget = tGrenade,
				}))
	
			end
	
		end

	end

end

function Alert:OnObjectApproaching (tObject, tInstigator)

	if tObject and tInstigator and not self:IsFriendlyFire (self.tHost, tInstigator) then

		if self:AddAttacker (tInstigator) then

			if not self:IsInState (GrenadeReaction) and 
				not self:IsInState (PropReaction) and 
				not self:IsInState (WoundedReaction) then

				self:PushState (Create (PropReaction, 
				{
					tTarget = tObject,
				}))

			end

		end

	end	

end

function Alert:OnWounded (tAttacker)

	if self:AddAttacker (tAttacker) then

		if not self:IsInState (GrenadeReaction) and 
			not self:IsInState (PropReaction) and 
			not self:IsInState (WoundedReaction) then
	
			self:PushState (Create (WoundedReaction, 
			{
				tTarget = tAttacker,
			}))

		end

	end

end

function Alert:OnAttacked (tAttacker)

	-- Ignore friendly fire
	if tAttacker and not self:IsFriendlyFire (self.tHost, tAttacker) then

		if self:AddAttacker (tAttacker) then
		
			if self:IsInState (WaitInCover) or self:IsInState (LeaveCover) then

				-- Turn to face the direction of the attack
				self:ChangeState (Create (FaceAttackDirection,
				{
					vTargetPosition = self.tAttackerPositions [tAttacker],
				}))

			end

		end

	end

end

function Alert:AddAttacker (tAttacker)

	-- Store the last attacker
	self.tAttacker = tAttacker

	-- Store the last attacker direction
	self.vAttackDirection = VecSubtract (tAttacker:RetCentre (), self.tHost:RetCentre ())

	-- Store current position
	self.vOriginalPosition = self.tHost:RetCentre ()

	-- The attacker is already visible, and we are not in the middle of a 'reaction'
	if self.tHost:IsVisible (tAttacker) and not self:IsLocked () then

		self.bAttackerFound = true
		self:Finish ()
		return false

	else

		-- Store the number of attackers
		if not self.tAttackerPositions [tAttacker] then
			self.nNumAttackers = self.nNumAttackers + 1
		end

		-- Store the position of the attacker
		self.tAttackerPositions [tAttacker] = tAttacker:RetEyePosition ()
		return true

	end

end

function Alert:AttackerFound ()
	return self.bAttackerFound
end

function Alert:IsLocked ()
	return self:IsInState (GrenadeReaction) or 
		self:IsInState (PropReaction) or 
		self:IsInState (WoundedReaction)
end
