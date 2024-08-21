----------------------------------------------------------------------
-- Name: ShootCorpse State
--	Description: Walk to the body and kick it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Equipment\\MoveToAndPrimaryFire"
require "State\\NPC\\Action\\Equipment\\Reload"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"

ShootCorpse = Create (MoveToAndPrimaryFire, 
{
	sStateName = "ShootCorpse",
	nMovementType = eMovementType.nWalk,
})

function ShootCorpse:OnEnter ()
	local tFirearm =  self.tHost:RetCurrentPrimaryEquipment ()
	assert (tFirearm)

	self.nCount = Min (5, tFirearm:RetMaxAmmoCount ())
	self.nRadius = 8

	-- Check parameters
	MoveToAndPrimaryFire.OnEnter (self)
end

function ShootCorpse:OnActiveStateFinished ()

	-- Finished reloading - cock weapon
	if self:IsInState (Reload) then

		self.tHost:SpeakAudio (eVocals.nInsultDead, "Yep, I'm bad")
		self:ChangeState (Create (FullBodyAnimate,
		{
			nAnimationID = eFullBodyAnimationID.nCockWeapon,		
		}))
		return true

	-- Finished cocking weapon - now shoot
	elseif self:IsInState (FullBodyAnimate) then
		
		self:ChangeState (Create (PrimaryFire, {}))			
		return true

	end

	-- Call parent
	return MoveToAndPrimaryFire.OnActiveStateFinished (self)
end

function ShootCorpse:EvaluateConditions ()

	if self:IsInState (MoveToTarget) then

		if self.tTargetInfo:CanPrimaryFire () and self:IsTargetInProximity (self.nProximityCheckID) then

			self:ChangeState (Create (Reload, {}))
		
		end

	end

end
