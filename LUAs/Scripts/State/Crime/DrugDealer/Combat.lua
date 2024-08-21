----------------------------------------------------------------------
-- Name: Combat State
--	Description: Derives from the gangster state which contains all the combat
-- behaviour, but remembers that it is part of the gang harassment crime and
-- resets to it when finished
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Character\\Gangster"
require "State\\NPC\\Action\\Idle\\Idle"

namespace ("DrugDealer")

Combat = Create (Gangster, 
{
	sStateName = "Combat",
})

----------------------------------------------------------------------
-- OnEnter
----------------------------------------------------------------------

function Combat:OnEnter ()
	-- Call parent
	Gangster.OnEnter (self)

	-- Check parameters
	assert (self.tEnemy)
	assert (self.tTeam)

	-- Push Idle state onto the stack - they will go back to this when they have finished attacking
	self:PushState (Create (Idle, {}))

	self:AttackEnemy (self.tEnemy)
end

----------------------------------------------------------------------
-- OnActiveStateFinished
----------------------------------------------------------------------

function Combat:OnActiveStateFinished ()
	-- Call parent
	if Gangster.OnActiveStateFinished (self) then

		-- If I am back in the idle state inform the mission
		if self:HasFinishedCombat () then
			self.tHost:NotifyCustomEvent ("CombatFinished")
			self.nTargetSelectionID = self.tTeam:RequestMostSuitableEnemy (self.tTeam, self.tHost)
		end
		return true

	end

	return false
end

----------------------------------------------------------------------
-- Handle events, return true if they have been handled
----------------------------------------------------------------------

function Combat:OnEvent (tEvent)

	if self:RetActiveState():IsA (Idle) then

		-- Damaged
		if tEvent:HasID (self.nDamagedID) then
	
			self:AttackEnemy (tEvent:RetInstigator ())
			return true
		
		-- Enemy appeared
		elseif tEvent:HasID (self.nEnemyAppearedID) then

			self:AttackEnemy (tEvent:RetEnemy ())
			return true

		-- Footstep sound
		elseif tEvent:HasID (self.nFootstepSoundID) then
	
			-- Attack the source (if it is an enemy)
			self:AttackEnemy (tEvent:RetSource ())
			return true
		
		-- Weapon sound
		elseif tEvent:HasID (self.nWeaponSoundID) then
	
			-- Attack the owner (if it is an enemy)
			local tOwner = tEvent:RetSource()
			self:AttackEnemy (tOwner)
			return true
	
		-- Grenade landed nearby
		elseif tEvent:HasID (self.nGrenadeSoundID) then
	
			self:PushState (Create (FleeGrenade, 
			{
				tGrenade = tEvent:RetSource (),
			}))
			return true

		-- An enemy has been added by someone in the team
		elseif self.tTeam and tEvent:HasID (self.nTeamEnemyAddedID) then
	
			-- Re-request a suitable enemy from the team object
			self.nTargetSelectionID = self.tTeam:RequestMostSuitableEnemy (self.tTeam, self.tHost)
			return true

		-- An enemy has been sighted by someone in the team
		elseif self.tTeam and tEvent:HasID (self.nTeamEnemyAppearedID) then
	
			-- Re-request a suitable enemy from the team object
			self.nTargetSelectionID = self.tTeam:RequestMostSuitableEnemy (self.tTeam, self.tHost)
			return true

		-- A suitable enemy has been found by the team object
		elseif self.tTeam and tEvent:HasID (self.nSuitableEnemyID) and tEvent:HasTargetSelectionID (self.nTargetSelectionID) then
	
			if tEvent:Success () then
				self:AttackEnemy (tEvent:RetEnemy ())
			end
			return true

		end
	
	end

	-- Call parent
	return Gangster.OnEvent(self, tEvent)
end

-- Return true if the NPC is no longer attacking anything
function Combat:HasFinishedCombat ()
	local tState = self:RetActiveState ()
	return tState:IsA (Idle) or tState:IsA (Flee)
end
