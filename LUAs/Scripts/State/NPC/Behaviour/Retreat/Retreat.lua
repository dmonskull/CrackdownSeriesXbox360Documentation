----------------------------------------------------------------------
-- Name: Retreat State
--	Description: Flee from enemy
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Animation\\Flee"
require "State\\NPC\\Action\\Equipment\\StoreItem"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeReaction"
require "State\\NPC\\Behaviour\\PropReaction\\PropReaction"
require "State\\NPC\\Behaviour\\WoundedReaction\\WoundedReaction"

Retreat = Create (TargetState, 
{
	sStateName = "Retreat",
})

function Retreat:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	self:PushState (Create (Flee, {}))

	-- Store weapon if we have one
	self:PushState (Create (StoreItem, {}))

	-- Subscribe events
	self.nDamagedID = self:SubscribeImmediate (eEventType.AIE_DAMAGE_TAKEN, self.tHost)
	self.nGrenadeSoundID = self:SubscribeImmediate (eEventType.AIE_GRENADE_SOUND, self.tHost)
	self.nGrenadeVocalID = self:SubscribeImmediate (eEventType.AIE_GRENADE_VOCAL, self.tHost)
	self.nTouchedGrenadeID = self:SubscribeImmediate (eEventType.AIE_TOUCHED_GRENADE, self.tHost)
	self.nObjectApproachingID = self:SubscribeImmediate (eEventType.AIE_OBJECT_APPROACHING, self.tHost)
	self.nShotInLegID = self:SubscribeImmediate (eEventType.AIE_SHOT_IN_LEG, self.tHost)
end

function Retreat:OnEvent (tEvent)

	if tEvent:HasID (self.nDamagedID) then

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

function Retreat:OnDamaged (tInstigator)

	if tInstigator and not self:IsFriendlyFire (self.tHost, tInstigator) then

		-- Magically know where the target is if he shoots me
		if AILib.IsSameObject (self.tTargetInfo:RetTarget (), tInstigator) then
			self.tTargetInfo:Reveal ()
		end

		-- Shout in pain
		self.tHost:ShoutPainAudio (eVocals.nInsult, "I'm getting the Hell out of here!", tInstigator)

	end

end

function Retreat:OnDetectedGrenade (tGrenade)

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

function Retreat:OnObjectApproaching (tObject, tInstigator)

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

function Retreat:OnWounded (tAttacker)

	if not self:IsInState (GrenadeReaction) and 
		not self:IsInState (PropReaction) and 
		not self:IsInState (WoundedReaction) then

		self:PushState (Create (WoundedReaction, 
		{
			tTarget = tAttacker,
		}))

	end

end

function Retreat:IsLocked ()
	return self:IsInState (GrenadeReaction) or 
		self:IsInState (PropReaction) or 
		self:IsInState (WoundedReaction)
end
