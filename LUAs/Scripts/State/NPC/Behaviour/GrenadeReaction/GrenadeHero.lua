----------------------------------------------------------------------
-- Name: Hero State
--	Description: Tries to pick up the grenade and throw it back
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Behaviour\\Attack\\PropAttack"

GrenadeHero = Create (PropAttack, 
{
	sStateName = "GrenadeHero",
	nMovementType = eMovementType.nSprint,
})

function GrenadeHero:OnEnter ()
	-- Check parameters
	assert (self.tGrenade)

	self.tProp = self.tGrenade
	self.tTarget = self.tGrenade:RetActivator ()

	-- Call parent
	PropAttack.OnEnter (self)
	
	-- Subscribe to events
	self.nGrenadeExplodedID = self:Subscribe (eEventType.AIE_GRENADE_EXPLODED, self.tGrenade)
end

function GrenadeHero:OnEvent (tEvent)

	if tEvent:HasID (self.nGrenadeExplodedID) then

		self:Finish ()
		return true

	end

	-- Call parent
	return PropAttack.OnEvent (self, tEvent)
end
