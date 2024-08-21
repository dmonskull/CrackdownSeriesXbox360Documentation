----------------------------------------------------------------------
-- Name: Buyer State
--	Description: Gets harassed by gang members, and runs away
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Movement\\MoveAndFace"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

namespace ("DrugDealer")

Buyer = Create (State,
{
	sStateName = "Buyer",	
})

YesAnimation = Create (FullBodyAnimate,
{
	sStateName = "YesAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})

NoAnimation = Create (FullBodyAnimate,
{
	sStateName = "NoAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})

WalkToDealer = Create (GetInProximity, 
{
	sStateName = "WalkToDealer",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nHigh,
	nRadius = 1.4,
})

DealAnimation = Create (FullBodyAnimate,
{
	sStateName = "DealAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})
	
function Buyer:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tMission)
	assert (self.tDealer)
	
	-- Set target to be the harasser
	self.tHost:PushTarget (self.tDealer, true)		
		
	-- Subscribe events
	self.nDealerEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tDeal)	
		
end


function Buyer:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	-- Buyer has accepted offer of drugs
	if tState:IsA (YesAnimation) then
				
		-- Set state to idle to prevent multiple triggers!
		self:ChangeState (Create (Idle, {}))
		
		-- Inform mission (and dealer) of buyers decision
		self.tHost:NotifyCustomEvent ("BuyerAcceptsOffer")
		
		return true
		
	end
	
	-- Buyer has refused drugs
	if tState:IsA (NoAnimation) then

		-- Set state to idle to prevent multiple triggers!
		self:ChangeState (Create (Idle, {}))
		
		-- Inform mission (and dealer) of buyers decision
		self.tHost:NotifyCustomEvent ("BuyerRefusesOffer")	
		
			
		-- End this state
		self:Finish ()				
		
				
		return true
		
	end
	
	if tState:IsA (WalkToDealer) then
	
		-- Set state to idle to prevent multiple triggers!
		self:ChangeState (Create (Idle, {}))
	
		-- Inform dealer that buyer is close enough to do the deal
		self.tHost:NotifyCustomEvent ("ReadyToDeal")
		
		return true
		
	end
	
	if tState:IsA (DealAnimation) then
	
		-- Set state to idle to prevent multiple triggers!
		self:ChangeState (Create (Idle, {}))	
	
		self.tHost:Speak ("Thanks")
		
		-- End this state
		self:Finish ()	
		
		return true
		
	end	
	
	
	-- Call parent
	return State.OnActiveStateFinished (self)
end

function Buyer:OnEvent (tEvent)

	if tEvent:HasID (self.nDealerEventID) and tEvent:HasCustomEventID ("DealerEnticesBuyer") then
		
		-- Make buyer face dealer
		self:PushState (Create (Turn, {}))			 
	
--		local nDecision = cAIPlayer.Rand (1,2)
		local nDecision = 1
		
		if nDecision == 1 then
			
			-- Play Yes I want drugs animation
			self:ChangeState (Create (YesAnimation, {}))
			
			-- Make buyer turn to face dealer
			self:PushState (Create (Turn, {}))						
			
			self.tHost:Speak ("Yes please.")
		
		end
			
		if nDecision == 2 then
										
			-- Play No I dont want drugs animation
			self:ChangeState (Create (NoAnimation, {}))
			
			-- Make buyer turn to face dealer
			self:PushState (Create (Turn, {}))										
			
			self.tHost:Speak ("No thank you very much.")		
		
		end	
		return true
	
	end
	
	-- Dealer beckons dealer to do the deal
	if tEvent:HasID (self.nDealerEventID) and tEvent:HasCustomEventID ("DealerBeckonsBuyer") then
	
		self.tHost:Speak ("OK")
	
		self:ChangeState (Create (WalkToDealer, {}))				
		return true

	end
	
	-- Dealer and buyer do the deal
	if tEvent:HasID (self.nDealerEventID) and tEvent:HasCustomEventID ("DealIsBeginning") then
	
		self.tHost:Speak ("OK")
	
		-- Play deal animation
		self:ChangeState (Create (DealAnimation, {}))
		return true

	end
	
	-- Call parent
	return State.OnEvent (self, tEvent)
end

