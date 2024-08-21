----------------------------------------------------------------------
-- Name: Watch State
--	Description: Stand around and watch some kind of fight
-- Cheer and boo at appropriate moments
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Chase\\StayInProximity"
require "State\\NPC\\Behaviour\\Watch\\Cheer"
require "State\\NPC\\Behaviour\\Watch\\Boo"
require "State\\NPC\\Behaviour\\StandIdle"

Watch = Create (State, 
{
	sStateName = "Watch",
	bFollow = true,
	nMinDist = 3,
	nMaxDist = 5,
})

function Watch:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tEntity)

	-- Watch the object
	self:PushState (self:CreateWatchState (self.tEntity))

	-- Subscribe events
	self.nCorpseAppearedID = self:SubscribeImmediate (eEventType.AIE_CORPSE_APPEARED, self.tHost)
	self.nWeaponSoundID = self:SubscribeImmediate (eEventType.AIE_WEAPON_SOUND, self.tHost)
	self.nDangerVocalID = self:SubscribeImmediate (eEventType.AIE_DANGER_VOCAL, self.tHost)
	self.nPainVocalID = self:SubscribeImmediate (eEventType.AIE_PAIN_VOCAL, self.tHost)
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

end

function Watch:OnEvent (tEvent)

	if tEvent:HasID (self.nCorpseAppearedID) then

		self.tHost:SpeakAudio (eVocals.nFoundCorpse, "Hey look, it's a dead guy!")
		return true

	elseif tEvent:HasID (self.nWeaponSoundID) then

		local tTarget = tEvent:RetTarget ()
		if tTarget and tTarget:IsA (cCharacterEntityIF) then
			self:React (tEvent:RetSource (), tTarget)
		end
		return true

	elseif tEvent:HasID (self.nDangerVocalID) then

		self:React (tEvent:RetSource (), tEvent:RetEnemy ())
		return true

	elseif tEvent:HasID (self.nPainVocalID) then

		self:React (tEvent:RetAttacker (), tEvent:RetSource ())
		return true
	
	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function Watch:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (Cheer) then

		if tState:TargetDeleted () then
			self:ChangeState (self:CreateWatchState (nil))
		else
			self:ChangeState (self:CreateWatchState (tState.tTarget))
		end
		return true

	elseif tState:IsA (Boo) then

		if tState:TargetDeleted () then
			self:ChangeState (self:CreateWatchState (nil))
		else
			self:ChangeState (self:CreateWatchState (tState.tTarget))
		end
		return true

	elseif self:InWatchState () then

		self:ChangeState (self:CreateWatchState (nil))
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

function Watch:React (tAttacker, tAttacked)

	if self:InWatchState () and 
		tAttacker and 
		tAttacked and 
		tAttacker ~= self.tHost and 
		tAttacked ~= self.tHost then

		-- Boo if someone I don't like attacks someone I like
		if self.tHost:IsFriend (tAttacker) or not self.tHost:IsFriend (tAttacked) then

			self:ChangeState (Create (Cheer,
			{
				tTarget = tAttacked,
			}))

		else

			self:ChangeState (Create (Boo,
			{
				tTarget = tAttacker,
			}))

		end

	end

end

function Watch:CreateWatchState (tEntity)

	if tEntity then

		if self.bFollow then
	
			return Create (StayInProximity,
			{
				nMovementType = eMovementType.nWalk,
				nMinDist = self.nMinDist,
				nMaxDist = self.nMaxDist,
				tTarget = tEntity,
			})
	
		else
	
			return Create (Face,
			{
				tTarget = tEntity,			
			})
	
		end

	else

		return Create (StandIdle, {})

	end

end

function Watch:InWatchState ()
	return self:IsInState (StayInProximity) or self:IsInState (Face) or self:IsInState (StandIdle)
end
