---------------------------------------------------------------------
-- Name: MasterTutorial State
-- Description: The tutorial ambient crime
-- Owner: Your name here
-- (c) 2005 Real Time Worlds
---------------------------------------------------------------------

require "System\\State"
require "State\\Crime\\MasterTutorial\\MasterTutorialConversation"
require "State\\Crime\\MasterTutorial\\MasterTutorialFight"

MasterTutorial = Create (State,
{
	sStateName = "MasterTutorial"		-- State Name
})

function MasterTutorial:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Spawn NPCs and save pointers to them to member variables
	self.tNPC1 = cAIPlayer.SpawnNPCAtNamedLocation ("AIStreetSoldier5", "MasterTutorialSpawnPoint1")
	self.tNPC2 = cAIPlayer.SpawnNPCAtNamedLocation ("AICivilian4", "MasterTutorialSpawnPoint2")

	self.tNPC1:AddEquipment ("M16")
	self.tNPC2:AddEquipment ("M16")
	
	-- Set the NPCs team to the muchachos
	-- so that they will recognise the player as an enemy
	self.tNPC1:SetTeamSide (tMuchachos)
	self.tNPC2:SetTeamSide (tMuchachos)

	-- Push the TutorialConversation state onto the stack
	self:PushState (Create (MasterTutorialConversation,
	{
		tNPC1 = self.tNPC1,
		tNPC2 = self.tNPC2,
	}))

	-- Subscribe to damage events on both the NPCs
	self.nNPC1DamageTakenID = self:Subscribe (eEventType.AIE_DAMAGE_TAKEN, self.tNPC1)
	self.nNPC2DamageTakenID = self:Subscribe (eEventType.AIE_DAMAGE_TAKEN, self.tNPC2)

	-- Subscribe to death events on both the NPCs
	self.nNPC1DiedID = self:Subscribe (eEventType.AIE_DIED, self.tNPC1)
	self.nNPC2DiedID = self:Subscribe (eEventType.AIE_DIED, self.tNPC2)

end

function MasterTutorial:OnEvent (tEvent)

	if tEvent:HasID (self.nNPC1DamageTakenID) or
		tEvent:HasID (self.nNPC2DamageTakenID) then

		-- Make sure we are not already in the TutorialFight 
		-- state, so we don't push it onto the stack twice
		if not self:IsInState (MasterTutorialFight) then

			-- Get a pointer to the instigator of the damage
			local tInstigator = tEvent:RetInstigator ()
	
			-- Push the TutorialFight state onto the stack
			-- to attack the instigator of the damage
			self:PushState (Create (MasterTutorialFight,
			{
				tNPC1 = self.tNPC1,
				tNPC2 = self.tNPC2,
				tEnemy = tInstigator,
			}))

		end
		return true

	elseif tEvent:HasID (self.nNPC1DiedID) or
		tEvent:HasID (self.nNPC2DiedID) then

		-- One of the NPCs has died, so finish the Tutorial state
		self:Finish ()	
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end
