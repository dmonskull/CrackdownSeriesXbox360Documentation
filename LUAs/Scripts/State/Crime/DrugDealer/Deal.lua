----------------------------------------------------------------------
-- Name: Deal State
--	Description: Move in front of the victim, threaten them, then shoot them
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Character\\Pedestrian"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Movement\\MoveAndFace"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Chase\\Intercept"
require "State\\NPC\\Action\\Equipment\\EquipItem"

namespace ("DrugDealer")

Deal = Create (State,
{
	sStateName = "Deal",
})

EnticeAnimation = Create (FullBodyAnimate,
{
	sStateName = "EnticeAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})

BeckonAnimation = Create (FullBodyAnimate,
{
	sStateName = "BeckonAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})

DealAnimation = Create (FullBodyAnimate,
{
	sStateName = "DealAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})


function Deal:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tBuyer)
	assert (self.tMission)
	assert (self.nNumBodyGuards)

	-- Set target to be the buyer
	self.tHost:PushTarget (self.tBuyer, true)

	AILib.Emit ("Entice buyer")
	self.tHost:Speak ("Want some drugs?")
	
	-- Make dealer turn to face buyer
	self:PushState (Create (Turn, {}))	
	
	-- Play Entice animation
	self:PushState (Create (EnticeAnimation, {}))
	
	-- Make dealer turn to face buyer
	self:PushState (Create (Turn, {}))	

	-- Subscribe events - what is the buyer up to?
	self.nBuyerEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tBuyer)
	
	-- Subscribe events - what are the bodyguards up to?
	self.nShieldDealerEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tShieldDealer)
	
end

function Deal:OnActiveStateFinished ()

	-- Find out what the dealer has just finished doing
	local tState = self:RetActiveState ()
		
	-- Dealer has attempted to entice the buyer	
	if tState:IsA (EnticeAnimation) then
	
		-- Make dealer idle
		self:ChangeState (Create (Idle, {}))
	
		-- Inform mission (and other gang members) that the buyer has been enticed
		self.tHost:NotifyCustomEvent ("DealerEnticesBuyer")
	
		return true	
		
	end				
		
	-- Dealer has finished beckoning and buyer is about to approach
	if tState:IsA (BeckonAnimation) then

		-- Make dealer idle
		self:ChangeState (Create (Idle, {}))
				
		-- Inform mission (and other gang members) that buyer has been beckoned
		self.tHost:NotifyCustomEvent ("DealerBeckonsBuyer")
		
		return true
			
	end	
	
	-- Dealer has finished dealing
	if tState:IsA (DealAnimation) then

		-- Make dealer idle
		self:ChangeState (Create (Idle, {}))
				
		-- Inform mission (and other gang members) that deal is over
		self.tHost:NotifyCustomEvent ("DealFinished")
				
		return true
			
	end		
	
	-- Call parent
	return State.OnActiveStateFinished (self)
end

function Deal:OnEvent (tEvent)
	-- React to events

	-- Buyer has agreed to buy drugs
	if tEvent:HasID (self.nBuyerEventID) and tEvent:HasCustomEventID ("BuyerAcceptsOffer") then

		-- Dealer Beckons Buyer
		self.tHost:Speak ("Come over here")
			
		-- Play beckon animation
		self:ChangeState (Create (BeckonAnimation, {}))
		
		-- Make dealer turn to face buyer
		self:PushState (Create (Turn, {}))			
		
		return true

	end
	
	-- Buyer has turned down offer of drugs
	if tEvent:HasID (self.nBuyerEventID) and tEvent:HasCustomEventID ("BuyerRefusesOffer") then

		-- Dealer dismisses buyer
		self.tHost:Speak ("Please go away then.")		

		-- Make dealer idle
		self:ChangeState (Create (Idle, {}))
				
		-- Inform mission (and other gang members) that the buyer is not interested
		self.tHost:NotifyCustomEvent ("BuyerNotInterested")		
		
		return true

	end	
		
	-- Buyer has approached the Dealer and is ready to do business
	if tEvent:HasID (self.nBuyerEventID) and tEvent:HasCustomEventID ("ReadyToDeal") then

		-- Buyer is in position
--		self.tHost:Speak ("Lets do business")		

		-- set boolean for buyer in position to be true
		self.bReadyToDeal = true
		
		-- start function that checks for both buyer and a bodyguard to be in position
		self:OnDealReady ()
		
		return true
		
	end
		
	-- Bodyguard has approached and is ready to shield the deal
	if tEvent:HasID (self.nShieldDealerEventID) and tEvent:HasCustomEventID ("AllBodyGuardsInPosition") then

		-- BodyGuards are in position
		--self.tHost:Speak ("Lets do business")		
		
		-- set boolean for bodyguard in position to be true
		self.bBodyGuardsPositioned = true
		
		-- start function that checks for both buyer and a bodyguard to be in position		
		self:OnDealReady ()
		
		return true
	end			
	
	-- Call parent
	return State.OnEvent (self, tEvent)
end

	
function Deal:OnDealReady ()
 
 	local nNumBodyGuards = self.nNumBodyGuards
 
 	if nNumBodyGuards == 0 then
 	
	 	-- Play deal animation
		self:ChangeState (Create (DealAnimation, {}))
		
		-- Make dealer turn to face buyer
		self:PushState (Create (Turn, {}))			
		
		-- Inform buyer that deal is beginning - anims start simultaneously
		self.tHost:NotifyCustomEvent ("DealIsBeginning")
	 end	
 
 	-- Deal begins when both the buyer and the bodyguards are in position
 	 if self.bReadyToDeal and self.bBodyGuardsPositioned then
	 
 	 	-- Play deal animation
	 	self:ChangeState (Create (DealAnimation, {}))
	 	
	 	-- Make dealer turn to face buyer
	 	self:PushState (Create (Turn, {}))			
	 	
	 	-- Inform buyer that deal is beginning - anims start simultaneously
	 	self.tHost:NotifyCustomEvent ("DealIsBeginning")
	 end	 
	
end



