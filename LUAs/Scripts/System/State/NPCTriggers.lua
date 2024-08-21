----------------------------------------------------------------------
-- Name: NPC triggers
--	Description: Extends the State class - allows a state to subscribe to
-- a variety of common events for an NPC with a miminum of hassle and
-- repeated code
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function State:SubscribeNPCTriggerEvents (tNPC)
	
	-- Create a table to contain trigger event IDs for all NPCs
	if not self.tNPCTriggerEvents then
		self.tNPCTriggerEvents = {}
	end

	-- Create a sub-table to contain the trigger event IDs for this NPC
	local tNPCEvents = {}

	assert (not self.tNPCTriggerEvents[tNPC])
	self.tNPCTriggerEvents[tNPC] = tNPCEvents

	tNPCEvents.nDiedID = self:SubscribeImmediate (eEventType.AIE_DIED, tNPC)
	tNPCEvents.nDamagedID = self:SubscribeImmediate (eEventType.AIE_DAMAGE_TAKEN, tNPC)
	tNPCEvents.nEnemyAppearedID = self:SubscribeImmediate (eEventType.AIE_ENEMY_APPEARED, tNPC)
	tNPCEvents.nCorpseAppearedID = self:SubscribeImmediate (eEventType.AIE_CORPSE_APPEARED, tNPC)
	tNPCEvents.nSoundID = self:SubscribeImmediate (eEventType.AIE_SOUND, tNPC)
	tNPCEvents.nTouchedGrenadeID = self:SubscribeImmediate (eEventType.AIE_TOUCHED_GRENADE, tNPC)
	tNPCEvents.nTouchedID = self:SubscribeImmediate (eEventType.AIE_TOUCHED, tNPC)
	tNPCEvents.nObjectApproachingID = self:SubscribeImmediate (eEventType.AIE_OBJECT_APPROACHING, tNPC)

end

function State:UnsubscribeNPCTriggerEvents (tNPC)

	-- Get a pointer to the table containing trigger event IDs for this NPC
	assert (self.tNPCTriggerEvents)
	local tNPCEvents = self.tNPCTriggerEvents[tNPC]
	assert (tNPCEvents)

	self:Unsubscribe (tNPCEvents.nDiedID)
	self:Unsubscribe (tNPCEvents.nDamagedID)
	self:Unsubscribe (tNPCEvents.nEnemyAppearedID)
	self:Unsubscribe (tNPCEvents.nCorpseAppearedID)
	self:Unsubscribe (tNPCEvents.nSoundID)
	self:Unsubscribe (tNPCEvents.nTouchedGrenadeID)
	self:Unsubscribe (tNPCEvents.nTouchedID)
	self:Unsubscribe (tNPCEvents.nObjectApproachingID)

	self.tNPCTriggerEvents[tNPC] = nil

end

function State:OnNPCTriggerEvent (tEvent)

	if self.tNPCTriggerEvents then

		-- Loop through the NPCs
		for tNPC, tNPCEvents in pairs (self.tNPCTriggerEvents) do
			
			-- NPC died
			if tEvent:HasID (tNPCEvents.nDiedID) then
				
				-- Ignore friendly fire
				if tEvent:RetKiller () and not self:IsFriendlyFire (tNPC, tEvent:RetKiller ()) then
					self:OnNPCAttacked (tNPC, tEvent:RetKiller ())
				end
			
				self:OnNPCDied (tNPC, tEvent:RetKiller ())
				return true
			
			-- NPC took damage
			elseif tEvent:HasID (tNPCEvents.nDamagedID) then
			
				-- Ignore friendly fire
				if tEvent:RetInstigator () and not self:IsFriendlyFire (tNPC, tEvent:RetInstigator ()) then
					self:OnNPCAttacked (tNPC, tEvent:RetInstigator ())
				end
				return true
			
			-- NPC saw an enemy
			elseif tEvent:HasID (tNPCEvents.nEnemyAppearedID) then
			
				self:OnNPCDetectedEnemy (tNPC, tEvent:RetEnemy ())
				return true

			-- NPC saw a corpse
			elseif tEvent:HasID (tNPCEvents.nCorpseAppearedID) then

				self:OnNPCHeardInterestingSound (tNPC, tEvent:RetCorpse ())

				if self:IsCorpseSuspicious (tNPC, tEvent:RetCorpse ()) then
					self:OnNPCHeardSuspiciousSound (tNPC, tEvent:RetPosition ())
				end
				return true
			
			-- NPC heard a sound
			elseif tEvent:HasID (tNPCEvents.nSoundID) then

				-- NPC heard a grenade hit the ground
				if tEvent:IsA (AIE_GRENADE_SOUND) then

					-- Is the grenade a threat to me?
					if tEvent:RetSource () and self:IsGrenadeAThreat (tNPC, tEvent:RetSource ()) then
						self:OnNPCAttacked (tNPC, tEvent:RetActivator ())
					end
					self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())

				-- NPC heard a prop hit the ground
				elseif tEvent:IsA (AIE_PROP_SOUND) then

					-- If the prop is visible then the source of the suspicious sound is the person who 
					-- threw it, not the prop itself
					if tEvent:RetSource () and 
						tNPC:IsVisible (tEvent:RetSource ()) and
						self:IsSoundSuspicious (tEvent:RetActivator ()) then

						self:OnNPCHeardSuspiciousSound (tNPC, tEvent:RetPosition ())
					end

					-- Only considered interesting if prop is heavy
					if tEvent:RetSource () and
						tEvent:RetSource ():RetMass () > 50 then
				
						self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())
					end

				-- NPC heard a gunshot
				elseif tEvent:IsA (AIE_WEAPON_SOUND) or
					tEvent:IsA (AIE_BULLET_SOUND) then

					-- If I can see a friendly firing at an enemy, consider the enemy detected
					local tTarget = tEvent:RetTarget ()
					if tTarget and
						tTarget:IsA (cCharacterEntityIF) and
						tNPC:IsFriend (tEvent:RetSource ()) and 
						tNPC:IsVisible (tEvent:RetSource ()) and
						not self:IsFriendlyFire (tNPC, tTarget) then

						self:OnNPCDetectedEnemy (tNPC, tTarget)
					end
					self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())

				-- NPC heard an explosion
				elseif tEvent:IsA (AIE_EXPLOSION_SOUND) then

					self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())

				-- NPC heard someone shouting about a grenade
				elseif tEvent:IsA (AIE_GRENADE_VOCAL) then

					-- Is the grenade a threat to me?
					if tEvent:RetGrenade () and self:IsGrenadeAThreat (tNPC, tEvent:RetGrenade ()) then
						self:OnNPCAttacked (tNPC, tEvent:RetGrenade ():RetActivator ())
					end
					self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())

				-- NPC heard someone shouting indicating the presence of an enemy
				elseif tEvent:IsA (AIE_DANGER_VOCAL) then

					-- Is the person doing the shouting a friend and the enemy being shouted about an enemy of mine?
					if tEvent:RetSource () and
						tEvent:RetEnemy () and
						tNPC:IsFriend (tEvent:RetSource ()) and 
						not self:IsFriendlyFire (tNPC, tEvent:RetEnemy ()) then
						
						self:OnNPCDetectedEnemy (tNPC, tEvent:RetEnemy ())
					end
					self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())

				-- NPC heard someone shouting in pain
				elseif tEvent:IsA (AIE_PAIN_VOCAL) then

					-- Is the person doing the shouting a friend and the attacker an enemy of mine?
					if tEvent:RetSource () and
						tEvent:RetAttacker () and
						tNPC:IsFriend (tEvent:RetSource ()) and 
						not self:IsFriendlyFire (tNPC, tEvent:RetAttacker ()) then
						
						self:OnNPCAttacked (tNPC, tEvent:RetAttacker ())
					end
					self:OnNPCHeardInterestingSound (tNPC, tEvent:RetSource ())

				end
	
				-- Was the sound made by an enemy?
				if self:IsSoundSuspicious (tNPC, tEvent:RetSource ()) then
					self:OnNPCHeardSuspiciousSound (tNPC, tEvent:RetPosition ())
				end
				return true
			
			-- NPC was bumped into by someone - treat this as a suspicious sound
			elseif tEvent:HasID (tNPCEvents.nTouchedID) then
			
				if self:IsSoundSuspicious (tNPC, tEvent:RetToucher ()) then
					self:OnNPCHeardSuspiciousSound (tNPC, tEvent:RetPosition ())
				end
				return true
			
			-- NPC was hit by a grenade
			elseif tEvent:HasID (tNPCEvents.nTouchedGrenadeID) then
			
				if self:IsGrenadeAThreat (tNPC, tEvent:RetGrenade ()) then
					self:OnNPCAttacked (tNPC, tEvent:RetGrenade ():RetActivator ())
				end
				return true
			
			-- Fast-moving heavy object approaching
			elseif tEvent:HasID (tNPCEvents.nObjectApproachingID) then

				if tEvent:RetObject () and 
					tEvent:RetInstigator () and 
					not self:IsFriendlyFire (tNPC, tEvent:RetInstigator ()) then
					
					self:OnNPCAttacked (tNPC, tEvent:RetInstigator ())
				end
				return true

			end
	
		end
	
	end
	return false

end

function State:IsSoundSuspicious (tNPC, tSource)

	-- We magically know if the sound was made by an enemy even if we cannot see the source
	local bIsEnemy = false

	if tSource then

		if tSource:IsA (cProp) then
			
			local tActivator = tSource:RetActivator ()
			if tActivator and tActivator:IsA (cCharacterEntityIF) then
			
				bIsEnemy = tNPC:IsEnemy (tActivator)

			end
	
		elseif tSource:IsA (cCharacterEntityIF) then
	
			bIsEnemy = tNPC:IsEnemy (tSource)
	
		end

		if bIsEnemy then
		
			-- If the enemy who made the sound is not visible then it is 'suspicious'
			if not tNPC:IsVisible (tSource) then
				
				return true
				
			end
	
		end

	end
	return false

end

function State:IsCorpseSuspicious (tNPC, tCorpse)

	if tCorpse and tNPC:IsFriend (tCorpse) then

		return true

	end

end

function State:IsGrenadeAThreat (tNPC, tGrenade)

	-- Ignore friendly fire
	if tGrenade and tGrenade:RetActivator () and not self:IsFriendlyFire (tNPC, tGrenade:RetActivator ()) then

		-- Don't react to grenades that are not live or have already exploded
		if tGrenade:IsLive () and not tGrenade:HasExploded () then

			return true

		end

	end
	return false

end

function State:IsFriendlyFire (tNPC, tAttacker)

	-- Friendly fire is ignored unless it comes from the player
	if tAttacker and 
		(tNPC:IsFriend (tAttacker) or tNPC == tAttacker) and 
		not tAttacker:IsA (cPlayer) then

		return true

	end
	return false

end

-- Heard a sound made by an enemy whose location is not known
function State:OnNPCHeardSuspiciousSound (tNPC, vPosition)
end

-- Heard a sound indicating combat or danger is near, but not necesserily a threat
function State:OnNPCHeardInterestingSound (tNPC, tSource)
end

-- Took damage from an enemy - the attacker's location is not necessarily known
function State:OnNPCAttacked (tNPC, tAttacker)
end

-- Seen enemy, or was told about the location of the enemy by a team mate
function State:OnNPCDetectedEnemy (tNPC, tEnemy)
end

-- NPC died
function State:OnNPCDied (tNPC, tKiller)
end
