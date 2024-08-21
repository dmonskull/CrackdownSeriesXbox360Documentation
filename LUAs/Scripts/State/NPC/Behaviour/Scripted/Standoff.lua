----------------------------------------------------------------------
-- Name: Standoff State
--	Description: Face the target, play an annoyed animation.  Wait for the
-- target to go away.  If the target stays for too long, finish anyway but
-- set the Escalate flag, otherwise set the StandDown flag.
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Turn\\Face"

Standoff = Create (TargetState, 
{
	sStateName = "Standoff",
	nRadius = 5,
	nWaitTime = 10,
	nAnger = 0,
	bEscalate = false,
	bStandDown = false,
})

function Standoff:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Set proximity radius
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tTargetInfo:RetTarget (), self.nRadius)

	-- Turn to face the target
	self:PushState (Create (Turn, {}))

	-- Subscribe to events
	self.nTargetNotInProximityID = self:Subscribe (eEventType.AIE_TARGET_NOT_IN_PROXIMITY, self.tHost)
	self.nTargetDiedID = self:Subscribe (eEventType.AIE_DIED, self.tTargetInfo:RetTarget ())

end

function Standoff:OnActiveStateFinished ()

	local tState = self:RetActiveState ()
	
	if tState:IsA (Turn) then

		if self.tTargetInfo:IsTargetVisible () then

			-- Play the annoyed animation
			self:ChangeState (Create (FullBodyAnimate, 
			{
				nAnimationID = self:RetAnimationID (),
			}))
			self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, self:RetSpeech (), self.tTargetInfo:RetTarget ())
			self.nAnger = self.nAnger + 1

		else
			-- Target has gone away
			self.bStandDown = true
			self:Finish ()
		end
		return true

	elseif tState:IsA (FullBodyAnimate) then

		if self.nAnger > 2 then
			-- It's to time to move from insults to violence
			self.bEscalate = true
			self:Finish ()
		else
			-- Turn to face the target
			self:ChangeState (Create (Turn, {}))
		end
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function Standoff:RetAnimationID ()
	if self.nAnger == 0 then
		return eFullBodyAnimationID.nHarass
	elseif self.nAnger == 1 then
		return eFullBodyAnimationID.nTaunt2
	else
		return eFullBodyAnimationID.nTaunt5
	end
end

function Standoff:RetSpeech ()
	if self.nAnger == 0 then
		return "Get out of my way"
	elseif self.nAnger == 1 then
		return "Hey gringo, get the fuck out of my way!"
	else
		return "Right, you die"
	end
end

function Standoff:OnEvent (tEvent)

	-- Target has moved away, stand down
	if tEvent:HasID (self.nTargetNotInProximityID) and tEvent:HasProximityCheckID (self.nProximityCheckID) then

		self.bStandDown = true
		self:Finish ()
		return true

	-- Target died for some reason, stand down
	elseif tEvent:HasID (self.nTargetDiedID) then

		self.bStandDown = true
		self:Finish ()
		return true

	-- Target deleted, stand down
	elseif tEvent:HasID (self.nTargetDeletedID) then

		self.bStandDown = true
		self.bTargetDeleted = true
		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Standoff:Escalate ()
	return self.bEscalate
end

function Standoff:StandDown ()
	return self.bStandDown
end
