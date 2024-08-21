----------------------------------------------------------------------
-- Name: Civilians Gang State
--	Description: Sets up relationships for the civilians
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Civilians = Create (State, 
{
	sStateName = "Civilians",
})

function Civilians:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Set up relationships - civilians fear gangs and are neutral to everyone else, including each other
	self.tHost:SetGangRelationship (tCivilians, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tAgency, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tMuchachos, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tMob, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tCorporation, eRelationship.nEnemy)

end
