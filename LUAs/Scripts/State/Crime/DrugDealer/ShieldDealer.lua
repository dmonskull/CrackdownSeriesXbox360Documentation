----------------------------------------------------------------------
-- Name: Taunt State
--	Description: Taunt the victim, then watch the execution
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Chase\\GetInProximity"

namespace ("DrugDealer")

ShieldDealer = Create (State,
{
	sStateName = "ShieldDealer",
})


DecideToSheildDealer = Create (GetInProximity,
{
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nHigh,
	nRadius = nRadius,
})

DecideToKeepWatch = Create (Idle, {})
			
			
function ShieldDealer:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tBuyer)
	assert (self.tDealer)
	assert (self.tBodyGuard)

	-- Set target to be the dealer
	self.tHost:PushTarget (self.tDealer, true)
	
	-- Remember the position the 
	--self.vReturnPos = self.tBodyGuard:RetPosition ()
				
	-- Subscribe events - What is the dealer up to?
	self.nDealerEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tDealer)
	
end

function ShieldDealer:OnActiveStateFinished ()

	-- Find out what the bodyguard has just finished doing
	local tState = self:RetActiveState ()

	-- Body guard has just got into position to shield the deal
	if tState:IsA (DecideToSheildDealer) then
		
		-- make bodyguard idle
		self:ChangeState (Create (Idle, {}))
		
		-- tell mission that deal can proceed
		self.tHost:NotifyCustomEvent ("AllBodyGuardsInPosition")			
			
		return true
		
	end
	
	-- Body guard has remained to keep watch
	if tState:IsA (DecideToKeepWatch) then
		
		-- make bodyguard idle
		self:ChangeState (Create (Idle, {}))
		
		
		
		
		
		-- tell mission that deal can proceed
--		self.tHost:NotifyCustomEvent ("AllBodyGuardsInPosition")			
			
		return true
			
	end
	
	
	
	-- Bodyguard has returned to his post
	if tState:IsA (Move) then
			
		-- make bodyguard idle
		self:ChangeState (Create (Idle, {}))
					
		return true			
	end
		
	-- Call parent
	return State.OnActiveStateFinished (self)
end


function ShieldDealer:OnEvent (tEvent)

	-- Dealer beckons dealer to do the deal
	if tEvent:HasID (self.nDealerEventID) and tEvent:HasCustomEventID ("DealerBeckonsBuyer") then
		
		local nChance = cAIPlayer.Rand (1,2)
		
		if nChance == 1 then
			
			self.tHost:Speak ("Coming Boss")
	
			-- Set up random distance and time factors		
			local nRadius = cAIPlayer.FRand (3.0,5.0)
			local nWaitTime = cAIPlayer.FRand (0,2)
	
			-- Add a turn command to stack (performed last)			
			self:PushState (Create (Turn, {}))
			
			-- Add a getinproximity command to stack (performed second)
--			self:PushState (Create (GetInProximity, 
--			{
--				nMovementType = eMovementType.nWalk,
--				nMovementPriority = eMovementPriority.nHigh,
--				nRadius = nRadius,
--			}))				
			self:PushState (Create (DecideToSheildDealer, {}))
	
				
			-- Add a wait command to stack (performed first)
			self:PushState (Create (Wait,
			{
				nWaitTime = nWaitTime
			}))					
		end
		
		if nChance == 2 then
		
			self.tHost:Speak ("I'll wait here")
			
			-- Add a turn command to stack (performed last)			
			self:PushState (Create (Turn, {}))
			
			self:PushState (Create (DecideToKeepWatch, {}))	
		end		
					
		return true
	end			
	
	-- Call parent
	return State.OnEvent (self, tEvent)
end
