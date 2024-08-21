---------------------------------------------------------------------
-- Name: MasterTutorialFight State
-- Description: Make the NPCs attack someone who attacked them
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
---------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Character\\StreetSoldier"

MasterTutorialFight = Create (State, 
{
	sStateName = "MasterTutorialFight",
})

function MasterTutorialFight:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- It is assumed that the pointers self.tNPC1, self.NPC2, and
	-- self.tEnemy will be initialised when the state is pushed
	-- onto the stack

	-- Make NPC1 attack the enemy
	self.tNPC1:SetState (Create (StreetSoldier,
	{
		tEnemy = self.tEnemy,
	}))

	-- Make NPC2 attack the enemy
	self.tNPC2:SetState (Create (StreetSoldier,
	{
		tEnemy = self.tEnemy,
	}))

	self.nNPC1IsIdleID = self:Subscribe (eEventType.AIE_IS_IDLE, self.tNPC1)
	self.nNPC2IsIdleID = self:Subscribe (eEventType.AIE_IS_IDLE, self.tNPC2)
end

function MasterTutorialFight:OnEvent (tEvent)

	-- Trap custom events from NPC1
	if tEvent:HasID (self.nNPC1IsIdleID) then

		self:OnRevertToIdle ()
		return true

	-- Trap custom events from NPC2
	elseif tEvent:HasID (self.nNPC2IsIdleID) then

		self:OnRevertToIdle ()
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function MasterTutorialFight:OnRevertToIdle ()

	-- We first need to make sure the both the NPCs have reverted
	-- to idle...

	if self.tNPC1:IsIdle () and
		self.tNPC2:IsIdle () then

		-- Finish the state (It will be popped, and
		-- TutorialConversation will be resumed)
		self:Finish ()
	end

end
