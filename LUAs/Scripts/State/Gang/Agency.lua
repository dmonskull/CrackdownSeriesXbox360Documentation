----------------------------------------------------------------------
-- Name: Agency Gang State
--	Description: Doesn't really do anything right now
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

Agency = Create (State, 
{
	sStateName = "Agency",
})

function Agency:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Set up relationships - Agency opposes all gangs and is neutral to civilians
	self.tHost:SetGangRelationship (tCivilians, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tAgency, eRelationship.nFriend)
	self.tHost:SetGangRelationship (tMuchachos, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tMob, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tCorporation, eRelationship.nEnemy)

end
