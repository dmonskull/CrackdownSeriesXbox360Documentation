----------------------------------------------------------------------
-- Name: GangMember State
--	Description: Stand around and fidget, or something
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

namespace ("DrugDealer")

BodyGuard = Create (State,
{
	sStateName = "BodyGuard",
	anAnimList =
	{
		eFullBodyAnimationID.nIdle1,
		eFullBodyAnimationID.nIdle2,
		eFullBodyAnimationID.nIdle3,
		eFullBodyAnimationID.nIdle4,
	},
})

function BodyGuard:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.vFacePoint)

	-- Save normal viewing distance, and set the viewing distance to something small so
	-- we will see enemies only when they are close to us
	self.nViewingDistance = self.tHost:RetViewingDistance ()
	self.tHost:SetViewingDistance (5)

	-- Set target to the facepoint
	self.tHost:PushTargetPosition (self.vFacePoint)
	
	--Face the point
	self:PushState (Create (Face, {}))
	
	-- Start looping timer
	self.nTimerID = self:AddTimer (cAIPlayer.FRand (10, 20), true)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

end

function BodyGuard:OnExit ()
	-- Call parent
	State.OnExit (self)

	-- Delete looping timer
	self:DeleteTimer (self.nTimerID)

	-- Reset viewing distance to the default
	self.tHost:SetViewingDistance (self.nViewingDistance)

	self.tHost:PopTarget ()
end

function BodyGuard:OnEvent (tEvent)

	if tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		-- Pick a random animation from the table
		local nAnimIndex = cAIPlayer.Rand (1, table.getn (self.anAnimList))

		-- Play a random idle animation
		self:PushState (Create (FullBodyAnimate,
		{
			nAnimationID = self.anAnimList[nAnimIndex],
			nBlendInTime = 0.5,
			nBlendOutTime = 0.5,
		}))
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
