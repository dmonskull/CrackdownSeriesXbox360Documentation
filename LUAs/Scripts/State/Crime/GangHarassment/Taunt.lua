----------------------------------------------------------------------
-- Name: Taunt State
--	Description: Taunt the victim, then watch the execution
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Idle\\WaitForProximity"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Chase\\StayInProximity"
require "State\\NPC\\Action\\Equipment\\EquipItem"

namespace ("GangHarassment")

Taunt = Create (TargetState,
{
	sStateName = "Taunt",
	bIntercepted = false,
	anTauntAnimList =
	{
		eFullBodyAnimationID.nTaunt1,
		eFullBodyAnimationID.nTaunt2,
		eFullBodyAnimationID.nTaunt3,
		eFullBodyAnimationID.nTaunt4,
		eFullBodyAnimationID.nTaunt5,
	},
})

-- First taunt
TauntAnimation1 = Create (FullBodyAnimate,
{
	sStateName = "TauntAnimation1",
})

-- Second taunt (a bit more menacing than the first)
TauntAnimation2 = Create (FullBodyAnimate,
{
	sStateName = "TauntAnimation2",
})

function Taunt:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.tTarget)
	assert (self.tHarasser)

	-- Make sure we have a gun
	self.tFirearm = self.tHost:RetCurrentPrimaryEquipment()
	assert (self.tFirearm)

	-- Wait for the victim to get in range
	self:PushState (Create (WaitForProximity, 
	{
		nRadius = cAIPlayer.Rand (4,12),
		tEntity = self.tTargetInfo:RetTarget (),
	}))

	-- Subscribe events
	self.nHarasserEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tHarasser)
	self.nVictimEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tTarget)

end

function Taunt:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (WaitForProximity) then

		-- Turn to face the victim
		self:ChangeState (Create (Turn, {}))
		return true

	elseif tState:IsA (Turn) then

		-- Pick a random animation from the table
		local nIndex = cAIPlayer.Rand (1, table.getn (self.anTauntAnimList))

		self:ChangeState (Create (TauntAnimation1, 
		{
			nAnimationID = self.anTauntAnimList[nIndex],
		}))
		return true

	elseif tState:IsA (TauntAnimation1) then
		
		self:ChangeState (Create (Face, {}))
		self:WalkTowardsVictim ()
		return true

	-- Wait for a short period, then walk towards the victim
	elseif tState:IsA (Wait) then

		local nRadius = cAIPlayer.FRand (2.5,3.5)
		self:ChangeState (Create (GetInProximity, 
		{
			nRadius = nRadius,
			nMovementType = eMovementType.nWalk,
		}))
		return true

	elseif tState:IsA (GetInProximity) then

		-- Pick a random animation from the table
		local nIndex = cAIPlayer.Rand (1, table.getn (self.anTauntAnimList))

		self:ChangeState (Create (TauntAnimation2, 
		{
			nAnimationID = self.anTauntAnimList[nIndex],
		}))

		self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "I taunt you!", tEntity)
		return true

	elseif tState:IsA (TauntAnimation2) then
		
		self:ChangeState (Create (Face, {}))
		return true

	elseif tState:IsA (EquipItem) then

		self:OnAttackStart ()
		return true

	elseif tState:IsA (Combat) then

		-- Popping the Attack state clears the target so we have to set it again
		self:ChangeState (Create (StayInProximity,
		{
			nMinDist = tState.nMinDist,
			nMaxDist = tState.nMaxDist,
			nMovementType = eMovementType.nWalk,
		}))
		return true

	end
	
	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function Taunt:OnEvent (tEvent)

	-- The 'harasser' has intercepted the victim
	if tEvent:HasID (self.nHarasserEventID) and tEvent:HasCustomEventID ("InterceptFinished") then

		self.bIntercepted = true
		self:WalkTowardsVictim ()
		return true

	-- Victim has finished backing off (and started fleeing)
	elseif tEvent:HasID (self.nVictimEventID) and tEvent:HasCustomEventID ("FleeStarted") then

		self:ChangeState (Create (EquipItem,
		{
			tEquipment = self.tFirearm,
		}))
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

-- The harasser is going to attack the victim - Bill added AttackAndStayInProximity/StayInProximity state changes to get multiple
--gang members attacking and chasing the victim. 
function Taunt:OnAttackStart ()

	local nMinDist = cAIPlayer.Rand (7,10)
	local nMaxDist = nMinDist + cAIPlayer.Rand (0,6)	
	local nAttackChance = cAIPlayer.Rand (1,3)

	if nAttackChance == 1 then

		-- Bill - Chase and shoot the vicitm at full speed
		self:ChangeState (Create (Combat, 
		{
--			Staying in proximity of target disabled for now, sorry - NJR
			nMinDist = nMinDist,
			nMaxDist = nMaxDist,
			nMovementType = eMovementType.nRun,
		}))

	elseif nAttackChance == 2 then

		-- Bill - Follow the and shoot the victim but walk
		self:ChangeState (Create (Combat, 
		{
--			Staying in proximity of target disabled for now, sorry - NJR
			nMinDist = nMinDist,
			nMaxDist = nMaxDist,
			nMovementType = eMovementType.nWalk,
		}))

	elseif nAttackChance == 3 then

		-- Bill - Chase the victim, ideally have them punch and kick at a later date
		self:ChangeState (Create (StayInProximity, 
		{
			nMinDist = nMinDist,
			nMaxDist = nMaxDist,
			nMovementType = eMovementType.nWalk,
		}))

	end	

end

-- Walk towards the victim when both the victim has been intercepted
-- AND we have finished the first taunt animation (popped back to Face state)
function Taunt:WalkTowardsVictim ()
	
	local tState = self:RetActiveState ()

	if self.bIntercepted and tState:IsA (Face) then

		local nWaitTime = cAIPlayer.Rand (0,2)

		--Wait requisite time
		self:ChangeState (Create (Wait,
		{
			nWaitTime = nWaitTime
		}))			
		
	end

end
