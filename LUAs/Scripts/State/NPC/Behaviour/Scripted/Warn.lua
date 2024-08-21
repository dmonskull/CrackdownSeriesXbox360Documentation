----------------------------------------------------------------------
-- Name: Warn State
--	Description: Warn an enemy not to come near
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

Warn = Create (TargetState, 
{
	sStateName = "Warn",
	anAnimList =
	{
		eFullBodyAnimationID.nHarass,
		eFullBodyAnimationID.nTaunt1,
		eFullBodyAnimationID.nTaunt2,
		eFullBodyAnimationID.nTaunt3,
		eFullBodyAnimationID.nTaunt4,
		eFullBodyAnimationID.nTaunt5,
	},
})

TurnStart = Create (Turn, 
{
	sStateName = "TurnStart",
})

TurnEnd = Create (Turn, 
{
	sStateName = "TurnEnd",
})

function Warn:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Turn to face the target
	self:PushState (Create (TurnStart, {}))
end

function Warn:OnActiveStateFinished ()

	if self:IsInState (TurnStart) then

		-- Pick a random animation from the table
		local nIndex = cAIPlayer.Rand (1, table.getn (self.anAnimList))

		-- Play warning animation
		self:ChangeState (Create (FullBodyAnimate,
		{
			nAnimationID = self.anAnimList[nIndex],
		}))

		self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "Just keep on moving", self.tTargetInfo:RetTarget ())
		return true

	elseif self:IsInState (FullBodyAnimate) then
	
		-- Turn to face the target again
		self:ChangeState (Create (TurnEnd,{}))	

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
