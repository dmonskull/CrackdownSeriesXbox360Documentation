----------------------------------------------------------------------
-- Name: TakeCover State
--	Description: Run to a position that is hidden from the enemy.  Fire at
-- the enemy while running (if possible).
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Turn\\Turn"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Movement\\MoveAndPrimaryFire"
require "State\\NPC\\Action\\Crouch\\Crouch"
require "State\\NPC\\Behaviour\\TakeCover\\TakeCoverTraversal"

TakeCover = Create (TargetState, 
{
	sStateName = "TakeCover",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
	nRadius = 20,
	bSuccess = false,
	bReachedCover = false,
	bCrouchAllowed = false,
	bCrouch = false,
})

function TakeCover:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Subscribe events
	self.nDamagedID = self:Subscribe (eEventType.AIE_DAMAGE_TAKEN, self.tHost)

	-- Start the Traversal service
	self:PushState (Create (TakeCoverTraversal, 
	{
		tDefendedObject = self.tDefendedObject,
		vDefendedPosition = self.vDefendedPosition,
		nRadius = self.nRadius,
		bCrouchAllowed = self.bCrouchAllowed,
	}))
end

function TakeCover:OnExit ()
	-- Call parent
	TargetState.OnExit (self)

	-- If we are crouched and the state exits unexpectedly then make sure we are not any more
	if self.bCrouch then
		self.tHost:UncrouchImmediately ()
	end
end

function TakeCover:OnActiveStateFinished ()
	
	local tState = self:RetActiveState ()
	
	if tState:IsA (TakeCoverTraversal) then

		-- Found a cover position
		if tState:Success () then

			-- Remember to crouch if the cover position requires it
			self.bCrouch = tState.bIsCrouching

			-- Run to the cover position, shooting if I have a gun
			if self.tHost:IsCurrentPrimaryEquipmentEquiped () then

				self:ChangeState (Create (MoveAndPrimaryFire,
				{
					nMovementType = eMovementType.nRun,
					vDestination = tState.vCoverPosition,
				}))

			else

				self:ChangeState (Create (Move,
				{
					nMovementType = eMovementType.nRun,
					vDestination = tState.vCoverPosition,
				}))

			end
			
			self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "Just you wait!", self.tTargetInfo:RetTarget ())

		else
			self.bSuccess = false
			self:Finish ()
		end
		return true

	elseif tState:IsA (Move) or tState:IsA (MoveAndPrimaryFire) then
	
		-- Remember that we are now in cover
		self.bReachedCover = true

		-- If crouching allowed then do so, otherwise just face target
		if self.bCrouch then
			self:ChangeState (Create (Crouch,	{}))
		else
			self:ChangeState (Create (Turn,	{}))
		end
		return true

	elseif tState:IsA (Crouch) then

		-- Turn to face last known target position
		self:ChangeState (Create (Turn,	{}))
		return true
	
	elseif tState:IsA (Turn) then
	
		self.bSuccess = true
		self:Finish ()
		return true
	
	end
	
	-- Call parent	
	return TargetState.OnActiveStateFinished (self)
end

-- Handle events
function TakeCover:OnEvent (tEvent)

	if tEvent:HasID (self.nDamagedID) then
		
		-- We magically know if it was the target that did it
		if AILib.IsSameObject (tEvent:RetInstigator (), self.tTargetInfo:RetTarget ()) then
	
			-- If the target was able to damage us after we have reached cover
			-- then our cover must not be very effective
			if self.bReachedCover then

				self.bSuccess = false
				self:Finish ()
			
			end

		end
		return true

	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function TakeCover:Success ()
	return self.bSuccess
end

function TakeCover:ReachedCover ()
	return self.bReachedCover
end
