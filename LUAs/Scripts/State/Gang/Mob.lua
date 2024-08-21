----------------------------------------------------------------------
-- Name: Mob Gang State
--	Description: Create missions and set up variables for the Mob
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
--require "State\\Mission\\Refinery\\Refinery"

Mob = Create (State, 
{
	sStateName = "Mob",
	
	--Ed's 
--	bRefinery = false,	
})

function Mob:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Set up relationships - The Mob hates the Agency and both the other gangs
	self.tHost:SetGangRelationship (tCivilians, eRelationship.nNeutral)
	self.tHost:SetGangRelationship (tAgency, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tMuchachos, eRelationship.nEnemy)
	self.tHost:SetGangRelationship (tMob, eRelationship.nFriend)
	self.tHost:SetGangRelationship (tCorporation, eRelationship.nEnemy)
	
	--* Ed's missions *--

--	-- The apartments mission
--	if self.bRefinery then
--		self.tRefineryMission = self:NewMission ("RefineryMission", self.tHost, "SP_RefineryCentre")
--		self.tRefineryMission:SetState(Refinery.Refinery)
--	end	
	

end
