----------------------------------------------------------------------
-- Name: GrenadeReaction State
-- Description: Encapsulates reacting to a grenade
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadePanicFreeze"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadePanic"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeRun"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeRunShout"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeShoutRun"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeSpinShoutRun"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeHero"
require "State\\NPC\\Behaviour\\GrenadeReaction\\GrenadeWatch"

GrenadeReaction = Create (TargetState, 
{
	sStateName = "GrenadeReaction",
	bTargetMandatory = false,
})

function GrenadeReaction:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Target is not mandatory as the state continues after the grande explodes
	-- but we expect to be given a target when we enter the state
	assert (self.tHost:HasTarget ())

	-- Subscribe events
	self.nGrenadeSoundID = self:SubscribeImmediate (eEventType.AIE_GRENADE_SOUND, self.tHost)
	self.nGrenadeVocalID = self:SubscribeImmediate (eEventType.AIE_GRENADE_VOCAL, self.tHost)
	self.nTouchedGrenadeID = self:SubscribeImmediate (eEventType.AIE_TOUCHED_GRENADE, self.tHost)
end

function GrenadeReaction:OnEvent (tEvent)

	-- If no reaction has been selected yet
	if not self:RetActiveState () then

		if tEvent:HasID (self.nTouchedGrenadeID) then

			-- Grenade hit me
			if self.tHost:RetPersonality () <= ePersonality.nCowardly then
				self:PushState (Create (GrenadePanicFreeze, {}))
			elseif self.tHost:RetPersonality () < ePersonality.nBrave then
				self:PushState (Create (GrenadeShoutRun, {}))
			else
				self:PushState (Create (GrenadeRun, {}))
			end
			return true

		elseif tEvent:HasID (self.nGrenadeSoundID) then

			if self.tHost:IsVisible (tEvent:RetSource ()) then

				-- Grenade landed in front of me
				if self.tHost:RetPersonality () <= ePersonality.nCowardly then
					self:PushState (Create (GrenadeShoutRun, {}))
				elseif self.tHost:RetPersonality () < ePersonality.nBrave then
					self:PushState (Create (GrenadeRunShout, {}))
				else
					self:PushState (Create (GrenadeRun, {}))
--					self:PushState (Create (GrenadeHero, {}))
				end

			else

				-- Grenade landed somewhere behind me
				if self.tHost:RetPersonality () <= ePersonality.nCowardly then
					self:PushState (Create (GrenadePanicFreeze, {}))
				elseif self.tHost:RetPersonality () < ePersonality.nBrave then
					self:PushState (Create (GrenadePanic, {}))
				else
					self:PushState (Create (GrenadeSpinShoutRun, {}))
				end

			end
			return true

		elseif tEvent:HasID (self.nGrenadeVocalID) then

			-- Heard someone shouting "Grenade!"
			if self.tHost:RetPersonality () <= ePersonality.nCowardly then
				self:PushState (Create (GrenadePanicFreeze, {}))
			elseif self.tHost:RetPersonality () < ePersonality.nBrave then
				self:PushState (Create (GrenadeRun, {}))
			else
				self:PushState (Create (GrenadeWatch, {}))
			end
			return true

		end
		
	end
	
	-- Call parent
	return State.OnEvent (self, tEvent)
end

function GrenadeReaction:OnActiveStateFinished ()
	self:Finish ()
	return true
end
