----------------------------------------------------------------------
-- Name: AttackEnemy State
--	Description: The gang members all attack an enemy, probably the player
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Crime\\DrugDealer\\Combat"

namespace ("DrugDealer")

AttackEnemy = Create (State,
{
	sStateName = "AttackEnemy",
})

function AttackEnemy:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tEnemy)

	-- Make the enemy a team enemy
	self.tParent.tTeam:AddEnemy (self.tEnemy)

	-- Set them all to use the Combat state
	for i=1, self.tParent:RetNumGangMembers () do

		self.tParent.atGangMember[i]:SetState (Create (Combat,
		{
			tEnemy = self.tEnemy,
			nShootingAccuracy = 30,
		}))

	end

end

function AttackEnemy:OnExit ()
	self.tParent.tTeam:ClearEnemyList ()
	State.OnExit (self)
end

-- One of the gangsters has gone idle
function AttackEnemy:OnEvent (tEvent)

	for i=1, self.tParent:RetNumGangMembers () do

		if tEvent:HasID (self.tParent.anGangMemberEventID[i]) and 
			tEvent:HasCustomEventID ("CombatFinished") then

			-- Count the idle gang members
			local n = 0
		
			for i=1, self.tParent:RetNumGangMembers () do
				if self.tParent.atGangMember[i]:RetState ():HasFinishedCombat () then
					n = n + 1
				end
			end
		
			-- If they are all idle then finish the state
			if n == self.tParent:RetNumGangMembers () then
				self:Finish ()
			end
			return true

		end

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
