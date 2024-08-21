----------------------------------------------------------------------
-- Name: Victim State
--	Description: Gets harassed by gang members, and runs away
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Animation\\TimedBackAway"
require "State\\NPC\\Action\\Animation\\Flee"

namespace ("LMAssault")

Victim = Create (TargetState,
{
	sStateName = "Victim",	
})

WalkToCenter = Create (Move,
{
	sStateName = "WalkToCenter",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nHigh,
})

WalkBackwards = Create (TimedBackAway,
{
	sStateName = "WalkBackwards",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nHigh,
	nTimeout = 5,
})

TauntResponseAnimation = Create (FullBodyAnimate,
{
	sStateName = "TauntResponseAnimation",
	nAnimationID = eFullBodyAnimationID.nUpYours,
})

CowerAnimation = Create (FullBodyAnimate,
{
	sStateName = "CowerAnimation",
	nAnimationID = eFullBodyAnimationID.nBackOff,
})

function Victim:OnEnter ()
	-- Check parameters
	assert (self.atGangMember)
	assert (self.tTarget)
	assert (self.vCenter)

	-- Call parent
	TargetState.OnEnter (self)

	-- Walk to the center of the gang circle
	self:PushState (Create (WalkToCenter,
	{
		vDestination = self.vCenter,
	}))

	-- Subscribe events
	self.nHarasserEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tTarget)
	self.nDamagedID = self:Subscribe (eEventType.AIE_DAMAGE_TAKEN, self.tHost)
end

function Victim:OnEvent (tEvent)

	-- The harasser has taunted me
	if tEvent:HasID (self.nHarasserEventID) and tEvent:HasCustomEventID ("TauntFinished") then

		-- Taunt him back
		self:ChangeState (Create (TauntResponseAnimation, {}))
		return true

	-- The harasser has drawn his weapon
	elseif tEvent:HasID (self.nHarasserEventID) and tEvent:HasCustomEventID ("WeaponDrawFinished") then

		-- Cower
		self:ChangeState (Create (CowerAnimation, {}))	
		return true

	elseif tEvent:HasID (self.nDamagedID) then

		-- If I am damaged before I am in the flee state this probably means the player
		-- is attacking me.  In this case, just go into the flee state early, this will trigger
		-- the other gang members to start chasing me
		if not self:IsInState (Flee) then
			self:Flee ()
		end
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Victim:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (WalkToCenter) then
		
		-- I have reached the center already without being harassed... 
		-- walk towards the harasser.  The harasser needs to be triggered by proximity to the victim.
		self:ChangeState (Create (GetInProximity, 
		{
			nMovementType = eMovementType.nWalk,
			nMovementPriority = eMovementPriority.nHigh,
			nRadius = 4,
		}))
		return true
	
	elseif tState:IsA (GetInProximity) then

		self:ChangeState (Create (Face, {}))
		return true

	elseif tState:IsA (CowerAnimation) then

		-- Walk backwards (while facing the harasser)
		self:ChangeState (Create (WalkBackwards,	{}))
		return true

	elseif tState:IsA (WalkBackwards) then

		self:Flee ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function Victim:Flee ()

	-- Inform the harasser that I have finished backing off
	self.tHost:NotifyCustomEvent ("FleeStarted")

	--Flee from the harasser
	self:ChangeState (Create (Flee, {}))

end

