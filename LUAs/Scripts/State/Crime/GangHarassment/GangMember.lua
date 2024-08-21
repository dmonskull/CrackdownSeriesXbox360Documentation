----------------------------------------------------------------------
-- Name: GangMember State
--	Description: Stand around and fidget, or something
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

namespace ("GangHarassment")

GangMember = Create (TargetState,
{
	sStateName = "GangMember",
	nTargetInfoFlags = 0,		-- Over-ride default flags since we don't need to perform visibility checks
	anIdleAnimList =
	{
		eFullBodyAnimationID.nIdle1,
		eFullBodyAnimationID.nIdle2,
		eFullBodyAnimationID.nIdle3,
		eFullBodyAnimationID.nIdle4,
	},
})

function GangMember:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Save normal viewing distance, and set the viewing distance to something small so
	-- we will see enemies only when they are close to us
	self.nViewingDistance = self.tHost:RetViewingDistance ()
	self.tHost:SetViewingDistance (5)
	
	--Face the point
	self:PushState (Create (Face, 
	{
		nTargetInfoFlags = 0,	-- Over-ride default flags since we don't need to perform visibility checks
	}))
	
	-- Start looping timer
	self.nTimerID = self:AddTimer (cAIPlayer.FRand (10, 20), true)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

end

function GangMember:OnExit ()
	-- Call parent
	TargetState.OnExit (self)

	-- Reset viewing distance to the default
	self.tHost:SetViewingDistance (self.nViewingDistance)
end

function GangMember:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		if self:IsInState (Face) then

			-- Pick a random animation from the table
			local nIndex = cAIPlayer.Rand (1, table.getn (self.anIdleAnimList))

			-- Play a random idle animation
			self:PushState (Create (FullBodyAnimate,
			{
				nAnimationID = self.anIdleAnimList[nIndex],
				nBlendInTime = 0.5,
				nBlendOutTime = 0.5,
			}))

		end
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
