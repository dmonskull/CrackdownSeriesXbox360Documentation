----------------------------------------------------------------------
-- Name: SearchPosition State
--	Description: Walk to a position, look around, then give up
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Behaviour\\Scripted\\LookAround"

SearchPosition = Create (State, 
{
	sStateName = "SearchPosition",
	bCanInterrupt = true,
	nInterruptTimeout = 2,
})

function SearchPosition:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.vPosition)

	-- Subscribe events
	self.nCorpseAppearedID = self:SubscribeImmediate (eEventType.AIE_CORPSE_APPEARED, self.tHost)
	self.nSoundID = self:SubscribeImmediate (eEventType.AIE_SOUND, self.tHost)
	self.nTouchedID = self:SubscribeImmediate (eEventType.AIE_TOUCHED, self.tHost)
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	self:PushState (Create (Move,
	{
		nMovementType = eMovementType.nWalk,
		vDestination = self.vPosition,
	}))
end

function SearchPosition:OnEvent (tEvent)

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
			self.tHost:SpeakAudio (eVocals.nInvestigating, "I think I heard him!")
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

function SearchPosition:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (Turn) then

		-- If the position is acceptable, go there, otherwise just stand and look around
		if self:IsValidPosition (tState.vTargetPosition) then

			self:ChangeState (Create (Move,
			{
				nMovementType = eMovementType.nWalk,
				vDestination = tState.vTargetPosition,
			}))

		else
			self:ChangeState (Create (LookAround, {}))
		end
		return true

	elseif tState:IsA (Move) then

		self:ChangeState (Create (LookAround, {}))
		return true

	elseif tState:IsA (LookAround) then

		self:Finish ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

-- Return true if the position is an acceptable one to go to
function SearchPosition:IsValidPosition (vPosition)

	if self.tDefendedObject then

		assert (self.nRadius)
		return AILib.CharacterPosDist (self.tDefendedObject, vPosition) < self.nRadius

	elseif self.vDefendedPosition then

		assert (self.nRadius)
		return AILib.Dist (self.vDefendedPosition, vPosition) < self.nRadius

	end
	return true

end

function SearchPosition:OnNPCHeardSuspiciousSound (tNPC, vPosition)

	-- Face direction of sound
	self:ChangeState (Create (Turn,
	{
		vTargetPosition = vPosition,
	}))

	-- Stop responding to new sounds for a short period of time
	self:ResetInterruptTimer ()

end

function SearchPosition:ResetInterruptTimer ()
	if self.nTimerID then
		self:DeleteTimer (self.nTimerID)
	end
	self.nTimerID = self:AddTimer (self.nInterruptTimeout, false)
	self.bCanInterrupt = false
end
