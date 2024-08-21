----------------------------------------------------------------------
-- Name: Listen State
--	Description: Stand still for a while.  If a sound is heard, turn towards it.
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Face"

Listen = Create (State, 
{
	sStateName = "Listen",
	bCanInterrupt = true,
	nInterruptTimeout = 2,
})

function Listen:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- If no position to face is specified then just face straight ahead
	self.vPosition = self.vPosition or self.tHost:RetPosFromYaw (10, 0)

	-- Subscribe events
	self.nCorpseAppearedID = self:SubscribeImmediate (eEventType.AIE_CORPSE_APPEARED, self.tHost)
	self.nSoundID = self:SubscribeImmediate (eEventType.AIE_SOUND, self.tHost)
	self.nTouchedID = self:SubscribeImmediate (eEventType.AIE_TOUCHED, self.tHost)
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	-- Face direction of sound
	self:PushState (self:CreateFaceState (self.vPosition))
end

function Listen:OnEvent (tEvent)

	if tEvent:HasID (self.nCorpseAppearedID) then

		if self.bCanInterrupt and self:IsCorpseSuspicious (self.tHost, tEvent:RetCorpse ()) then
			if cAIPlayer.Rand (1, 3) == 1 then
				-- Don't vocalise this event all the time
				-- pkg ( 29/9/05 due to feedback from pre x05 build )
				self.tHost:SpeakAudio (eVocals.nInvestigating, "I've got a bad feeling about this")
			end
			self:OnNPCHeardSuspiciousSound (self.tHost, tEvent:RetPosition ())
		end
		return true

	elseif tEvent:HasID (self.nSoundID) then

		if self.bCanInterrupt and self:IsSoundSuspicious (self.tHost, tEvent:RetSource ()) then
			self.tHost:SpeakAudio (eVocals.nInvestigating, "I heard something!")
			self:OnNPCHeardSuspiciousSound (self.tHost, tEvent:RetPosition ())
		end
		return true

	elseif tEvent:HasID (self.nTouchedID) then

		if self.bCanInterrupt and self:IsSoundSuspicious (self.tHost, tEvent:RetToucher ()) then
			self.tHost:SpeakAudio (eVocals.nInvestigating, "Something brushed against me!")
			self:OnNPCHeardSuspiciousSound (self.tHost, tEvent:RetPosition ())
		end
		return true

	elseif self.nTimerID and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		-- Timer has finished, we can now respond to new sounds
		self.bCanInterrupt = true
		self.nTimerID = nil
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function Listen:OnNPCHeardSuspiciousSound (tNPC, vPosition)
		-- Face direction of sound
	self:ChangeState (self:CreateFaceState (vPosition))

	-- Stop responding to new sounds for a short period of time
	self:ResetInterruptTimer ()
end

function Listen:CreateFaceState (vPosition)
	return Create (Face,
	{
		vTargetPosition = vPosition,
	})
end

function Listen:ResetInterruptTimer ()
	if self.nTimerID then
		self:DeleteTimer (self.nTimerID)
	end
	self.nTimerID = self:AddTimer (self.nInterruptTimeout, false)
	self.bCanInterrupt = false
end
