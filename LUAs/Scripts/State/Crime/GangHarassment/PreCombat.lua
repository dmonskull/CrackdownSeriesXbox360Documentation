----------------------------------------------------------------------
-- Name: PreCombat State
--	Description: Taunt an enemy, probably the player
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Turn\\WaitForProximityAndFace"
require "State\\NPC\\Action\\Idle\\WaitForProximity"

namespace ("GangHarassment")

PreCombat = Create (TargetState,
{
	sStateName = "PreCombat",
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
TauntEnemyAnimation1 = Create (FullBodyAnimate,
{
	sStateName = "TauntEnemyAnimation1",
})

-- Second taunt (a bit more menacing than the first)
TauntEnemyAnimation2 = Create (FullBodyAnimate,
{
	sStateName = "TauntEnemyAnimation2",
})

function PreCombat:OnEnter ()
	-- Check parameters
	assert (self.tTarget)

	-- Call parent
	TargetState.OnEnter (self)

	-- Save normal viewing distance, and set the viewing distance to something small so
	-- we will see enemies only when they are close to us
	self.nViewingDistance = self.tHost:RetViewingDistance ()
	self.tHost:SetViewingDistance (10)

	-- Wait for the enemy to get in range
	self:PushState (Create (WaitForProximity, 
	{
		nRadius = cAIPlayer.Rand (2,6),
		tEntity = self.tTargetInfo:RetTarget (),
	}))

end

function PreCombat:OnExit ()
	-- Call parent
	TargetState.OnExit (self)

	-- Reset viewing distance to the default
	self.tHost:SetViewingDistance (self.nViewingDistance)
end

function PreCombat:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (WaitForProximity) then

		-- Turn to face the enemy
		self:ChangeState (Create (Turn, {}))
		return true

	elseif tState:IsA (Turn) then

		-- Pick a random animation from the table
		local nIndex = cAIPlayer.Rand (1, table.getn (self.anTauntAnimList))

		self:ChangeState (Create (TauntEnemyAnimation1, 
		{
			nAnimationID = self.anTauntAnimList[nIndex],
		}))

		self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "I taunt you!", self.tEntity)
		return true

	elseif tState:IsA (TauntEnemyAnimation1) then
		
		-- Wait for proximity, facing the enemy this time
		self:ChangeState (Create (WaitForProximityAndFace, 
		{
			nRadius = cAIPlayer.Rand (2,6)
		}))
		return true

	elseif tState:IsA (WaitForProximityAndFace) then

		self:ChangeState (Create (TauntEnemyAnimation2,
		{
			nAnimationID = eFullBodyAnimationID.nHarass,	-- a more aggressive taunt animation
		}))
		self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "I taunt you a second time!", self.tEntity)
		return true

	elseif tState:IsA (TauntEnemyAnimation2) then

		self:PopState ()
		self.tHost:NotifyCustomEvent ("FinishedTaunting")
		return true

	end
	
	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
