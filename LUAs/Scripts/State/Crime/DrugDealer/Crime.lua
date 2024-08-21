----------------------------------------------------------------------
-- Name: Crime State
--	Description: The gang members harass the pedestrian
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Crime\\DrugDealer\\Deal"
require "State\\Crime\\DrugDealer\\ShieldDealer"
require "State\\Crime\\DrugDealer\\Buyer"

namespace ("DrugDealer")

Crime = Create (State,
{
	sStateName = "Crime",
})

function Crime:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tBuyer)
	assert (self.tDealer)
	assert (self.atBodyGuard)
	
	
	--Set up gang members to harass victim
	for i=1, self:RetNumGangMembers () do
		
		self.atBodyGuard[i]:SetState (Create (ShieldDealer,
		{
			tBodyGuard = self.atBodyGuard[i],
			tBuyer = self.tBuyer,
			tDealer = self.tDealer,			
		}))
	end	
	
		
	-- Set up buyer
	self.tBuyer:SetState (Create (Buyer,
	{
		tMission = self,
		tDealer = self.tDealer,
	}))
	
	self.tDealer:SetState (Create (Deal,
	{
		tMission = self,
		tBuyer = self.tBuyer,
		nNumBodyGuards = self:RetNumGangMembers ()
	}))
		
	-- Subscribe to the victim deleted event
--	self.nVictimDeletedID = self:Subscribe (eEventType.AIE_OBJECT_DELETED, self.tVictim:RetCharacter())

	-- Subscribe events
	self.nDealEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tDeal)
	
end

function Crime:OnEvent (tEvent)

	if tEvent:HasID (self.nDealEventID) and tEvent:HasCustomEventID ("DealFinished") then
		
		self:Finish ()
		return true
	end
	
	if tEvent:HasID (self.nDealEventID) and tEvent:HasCustomEventID ("BuyerNotInterested") then
		
		self:Finish ()
		return true
	end	
	
		
	-- Call Parent
	return State.OnEvent (self, tEvent)
end

	
function Crime:OnExit ()
	-- Call parent
	State.OnExit (self)
	
	self.tBuyer:SetState (Pedestrian)
end

function Crime:RetNumGangMembers ()
	return table.getn (self.atBodyGuard)
end