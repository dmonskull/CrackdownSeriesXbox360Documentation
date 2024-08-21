----------------------------------------------------------------------
-- Name: TargetedTest Script
-- Description: Example script for a character who reacts when targeted
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Character\\PassiveGangster"

TargetedPassiveGangster = Create (PassiveGangster,
{
	sStateName = "TargetedPassiveGangster",
})

function TargetedPassiveGangster:OnEnter ()
	-- Call parent
	PassiveGangster.OnEnter (self)

	-- Subscribe events
	self.nTargetedID = self:Subscribe (eEventType.AIE_TARGETED, self.tHost)
	self.nEnemyAppearedID = self:Subscribe (eEventType.AIE_ENEMY_APPEARED, self.tHost)
end

function TargetedPassiveGangster:OnEvent (tEvent)

	if tEvent:HasID (self.nTargetedID) then

		-- If the targeter is an enemy and is visible then attack them
		local tTargeter = tEvent:RetTargeter ()
		if self.tHost:IsEnemy (tTargeter) and
			self.tHost:IsVisible (tTargeter) then
			
			self:OnTargeted (tTargeter)

		end
		return true

	elseif tEvent:HasID (self.nEnemyAppearedID) then

		-- If the enemy is targeting me then attack them
		local tEnemy = tEvent:RetEnemy ()
		if tEnemy:RetTarget () == self.tHost then

			self:OnTargeted (tEnemy)

		end
		return true

	end

	-- Call parent
	return PassiveGangster.OnEvent (self, tEvent)
end

function TargetedPassiveGangster:OnTargeted (tTargeter)

	if self:IsFleeConditionSatisfied (tTargeter) then

		self:ChangeState (self:CreateFleeState (tTargeter))

	elseif self:IsAttackConditionSatisfied (tTargeter) then
		
		self:ChangeState (self:CreateAlertState (tTargeter))

	end

end

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1", nil, 5)
tNPC:AddEquipment ("M16")
tNPC:SetTeamSide (tMuchachos)
tNPC:SetPersonality (ePersonality.nNormal)
tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)
tNPC:SetState (TargetedPassiveGangster)
