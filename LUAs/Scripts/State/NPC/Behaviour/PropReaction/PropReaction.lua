----------------------------------------------------------------------
-- Name: PropReaction State
--	Description: Dodge out of the way of an oncoming prop (or other heavy
-- fast-moving object)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Dodge\\TimedDodge"
require "State\\NPC\\Behaviour\\PropReaction\\PropPanicFreeze"
require "State\\NPC\\Behaviour\\PropReaction\\PropCloseAttack"
require "State\\NPC\\Behaviour\\PropReaction\\PropPrimaryFire"

PropReaction = Create (TargetState, 
{
	sStateName = "PropReaction",
})

function PropReaction:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	if self.tHost:IsInViewCone (self.tTargetInfo:RetLastTargetCentrePosition ()) then

		-- We can see the prop so react immediately
		self:PushState (self:CreateReactionState ())

	else

		-- We cannot see the prop so turn to face it first
		self:PushState (Create (Turn, {}))

	end

end

function PropReaction:OnActiveStateFinished ()

	if self:IsInState (Turn) then

		self:ChangeState (self:CreateReactionState ())
		return true

	end

	self:Finish ()
	return true
end

function PropReaction:CreateReactionState ()

	if self.tHost:RetPersonality () <= ePersonality.nCowardly then

		-- Panic and freeze animation
		return Create (PropPanicFreeze, {})

	elseif self.tHost:RetPersonality () < ePersonality.nBrave then

		-- Dodge out of way
		return Create (TimedDodge, {})

	else

		-- Try and shoot or punch the prop out of the way if it is small enough
		-- Otherwise just dodge out of the way
		if self.tTargetInfo:RetTarget ():RetMass () <= 20 then

			if self.tHost:IsCurrentPrimaryEquipmentEquiped () and
				not self.tHost:RetCurrentPrimaryEquipment ():IsEmpty () then

				return Create (PropPrimaryFire, {})

			else
				-- PropCloseAttack doesn't work very well right now - NJR
				-- return Create (PropCloseAttack, {})
				return Create (TimedDodge, {})
			end

		else
			return Create (TimedDodge, {})
		end

	end

end
