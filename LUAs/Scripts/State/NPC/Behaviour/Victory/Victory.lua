----------------------------------------------------------------------
-- Name: Victory State
--	Description: Play a 'victory' animation and say something appropriate
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Behaviour\\Victory\\SpitOnCorpse"
require "State\\NPC\\Behaviour\\Victory\\StampOnCorpse"
require "State\\NPC\\Behaviour\\Victory\\ShootCorpse"

Victory = Create (TargetState, 
{
	sStateName = "Victory",
})

function Victory:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)
	
	local nRand
	if self.tHost:IsCurrentPrimaryEquipmentEquiped () then
		nRand = cAIPlayer.Rand (1, 3)
	else
		nRand = cAIPlayer.Rand (1, 2)
	end

	if nRand == 1 then
	
		self:PushState (Create (SpitOnCorpse, 
		{
			tTarget = tTarget,
		}))

	elseif nRand == 2 then
	
		self:PushState (Create (StampOnCorpse, 
		{
			tTarget = tTarget,
		}))
	
	elseif nRand == 3 then

		self:PushState (Create (ShootCorpse, 
		{
			tTarget = tTarget,
		}))

	end
	
	-- Subscribe events
	self.nReincarnatedID = self:Subscribe (eEventType.AIE_REINCARNATED, self.tTargetInfo:RetTarget ())
end

function Victory:OnEvent (tEvent)

	if tEvent:HasID (self.nReincarnatedID) then

		-- If the player reincarnates while we are dancing on his corpse then bail out immediately
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Victory:OnActiveStateFinished ()
	self:Finish ()
	return true
end
