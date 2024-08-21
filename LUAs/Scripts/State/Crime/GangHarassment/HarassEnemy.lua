----------------------------------------------------------------------
-- Name: HarassEnemy State
--	Description: The gang members all taunt an enemy, probably the player
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Mission\\MissionState"
require "State\\Crime\\GangHarassment\\PreCombat"

namespace ("GangHarassment")

HarassEnemy = Create (State,
{
	sStateName = "HarassEnemy",
	bEscalate = false,
	bStandDown = false,
})

function HarassEnemy:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tEnemy)

	self.anGangMemberEventID = {}

	for i, tGangMember in pairs (self.tParent.atGangMember) do

		-- Set them all to use the PreCombat state
		tGangMember:SetState (Create (PreCombat,
		{
			tTarget = self.tEnemy,
		}))

		-- Subscribe events
		self.anGangMemberEventID[i] = self:Subscribe (eEventType.AIE_CUSTOM, tGangMember)

	end

	-- Set up proximity check to determine when enemy has gotten too far away
	self.nProximityCheckID = self:AddProximityCheck (self.tHost, self.tEnemy, 10)

	-- Subscribe to events
	self.nTargetNotInProximityID = self:Subscribe (eEventType.AIE_TARGET_NOT_IN_PROXIMITY, self.tHost)

end

function HarassEnemy:OnExit ()
	State.OnExit (self)
end

function HarassEnemy:OnEvent (tEvent)

	-- The enemy is no longer visible to anyone in the team
	if tEvent:HasID (self.nTargetNotInProximityID) then

		self.bStandDown = true
		self:Finish ()
		return true

	end

	for i, nGangMemberEventID in pairs (self.anGangMemberEventID) do

		if tEvent:HasID (nGangMemberEventID) and 
			tEvent:HasCustomEventID ("FinishedTaunting") then

			self.bEscalate = true
			self:Finish ()
			return true
			
		end

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function HarassEnemy:Escalate ()
	return self.bEscalate
end

function HarassEnemy:StandDown ()
	return self.bStandDown
end
