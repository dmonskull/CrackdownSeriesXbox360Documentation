----------------------------------------------------------------------
-- Name: Corporation Gang State
--	Description: Create missions and set up variables for the Corporation
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Mission\\PRComplex\\PRComplex"
require "State\\Mission\\IntelComplex\\IntelComplex"

Corporation = Create (State, 
{
	sStateName = "Corporation",

	-- Bill's Missions 
	bPRComplex = false,
	
	-- Ed's Missions 
	bIntelComplex = false,

})

function Corporation:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Set up relationships - The Corporation hates the Agency and the Mob
	self.tHost:SetGangRelationship (tCivilians, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tAgency, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tMuchachos, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tMob, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tCorporation, eRelationship.nFriend)
	
	-- Bill's 
	-- The PR Complex mission
	if self.bPRComplex then
		self.tPRComplex = self:NewMission ("PRComplexMission", self.tHost, "SP_PR_Boss")
		self.tPRComplex:SetState (PRComplex.PRComplex)
	end
	
	
	
	-- Ed's 
	-- The Intel Complex mission
	if self.bIntelComplex then
		self.tIntelComplex = self:NewMission ("IntelComplexMission", self.tHost, "SP_PR_Boss")
		self.tIntelComplex:SetState (IntelComplex.IntelComplex)
	end


end
