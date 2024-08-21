----------------------------------------------------------------------
-- Name: Harass State
--	Description: Move in front of the victim, threaten them, then shoot them
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Character\\Pedestrian"
require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Turn\\WaitForProximityAndFace"
require "State\\NPC\\Action\\Chase\\GetInProximity"
require "State\\NPC\\Action\\Chase\\Intercept"
require "State\\NPC\\Action\\Equipment\\EquipItem"

namespace ("LMAssault")

Harass = Create (TargetState,
{
	sStateName = "Harass",
})

HarassAnimation = Create (FullBodyAnimate,
{
	sStateName = "HarassAnimation",
	nAnimationID = eFullBodyAnimationID.nHarass,
})

CockWeaponAnimation = Create (FullBodyAnimate,
{
	sStateName = "CockWeaponAnimation",
	nAnimationID = eFullBodyAnimationID.nCockWeapon,
})

GiveUpAnimation = Create (FullBodyAnimate,
{
	sStateName = "GiveUpAnimation",
	nAnimationID = eFullBodyAnimationID.nGiveUp,
})

VictoryAnimation = Create (FullBodyAnimate,
{
	sStateName = "VictoryAnimation",
	nAnimationID = eFullBodyAnimationID.nVictory,
})

WalkToBody = Create (GetInProximity,
{
	sStateName = "WalkToBody",
	nMovementType = eMovementType.nWalk,
	nMovementPriority = eMovementPriority.nHigh,
	nRadius = 3,
})

function Harass:OnEnter ()
	-- Check parameters
	assert (self.tTarget)

	-- Call parent
	TargetState.OnEnter (self)

	-- Make sure we have a gun
	self.tFirearm = self.tHost:RetCurrentPrimaryEquipment()
	assert (self.tFirearm)

	-- Wait for the victim to get in range
	self:PushState (Create (WaitForProximityAndFace,
	{
		nRadius = 6,
	}))

	-- Subscribe events
	self.nVictimEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tTarget)

end

function Harass:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	-- Victim is near enough
	if tState:IsA (WaitForProximityAndFace) then

		-- Intercept the victim
		self:ChangeState (Create (Intercept, 
		{
			nMovementType = eMovementType.nWalk,
			nMovementPriority = eMovementPriority.nHigh,
		}))
		return true

	-- Intercepted victim
	elseif tState:IsA (Intercept) then

		-- Inform the other gang members that the victim has been intercepted
		self.tHost:NotifyCustomEvent ("InterceptFinished")

		-- Play harassing animation
		self:ChangeState (Create (HarassAnimation, {}))
		return true

	-- Harass animation is finished
	elseif tState:IsA (HarassAnimation) then
		
		-- Inform the victim that I have finished taunting him
		self.tHost:NotifyCustomEvent ("TauntFinished")

		-- Draw weapon
		self:ChangeState (Create (EquipItem,
		{
			tEquipment = self.tFirearm,
		}))
		return true
	
	-- Draw weapon finished
	elseif tState:IsA (EquipItem) then

		-- Inform the victim that I have finished drawing my weapon
		self.tHost:NotifyCustomEvent ("WeaponDrawFinished")

		-- Play cock weapon animation
		self:ChangeState (Create (CockWeaponAnimation, {}))
		return true

	-- Cock weapon finished
	elseif tState:IsA (CockWeaponAnimation) then

		-- Just face the victim until we are triggered to attack
		self:ChangeState (Create (Face, {}))
		return true

	-- Attack state finished
	elseif tState:IsA (Combat) then

		if tState:TargetDied () then

			-- Walk towards the body
			self:ChangeState (Create (WalkToBody, {}))

		else

			-- Play give up animation
			self:ChangeState (Create (GiveUpAnimation, {}))

		end
		return true

	-- Walk to body finished
	elseif tState:IsA (WalkToBody) then
		
		-- Change victory animation
		self:ChangeState (Create (VictoryAnimation, {}))
		return true

	-- Give up animation finished
	elseif tState:IsA (GiveUpAnimation) then

		self.tHost:NotifyCustomEvent ("HarassFinished")
		self:PopState ()
		return true

	-- Victory animation finished
	elseif tState:IsA (VictoryAnimation) then
		
		self.tHost:NotifyCustomEvent ("HarassFinished")
		self:PopState ()
		return true

	end
	
	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end

function Harass:OnEvent (tEvent)

	-- Victim has finished backing off (and started fleeing)
	if tEvent:HasID (self.nVictimEventID) and tEvent:HasCustomEventID ("FleeStarted") then

		self:ChangeState (Create (Combat,
		{
--			Staying in proximity of target disabled for now, sorry - NJR
			nMinDist = 5,
			nMaxDist = 10,
		}))
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end
