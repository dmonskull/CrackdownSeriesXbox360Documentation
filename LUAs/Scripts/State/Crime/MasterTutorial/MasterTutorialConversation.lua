---------------------------------------------------------------------
-- Name: TutorialConversation State
-- Description: Make the NPCs talk to each other
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
---------------------------------------------------------------------

require "System\\State"
require "State\\Crime\\MasterTutorial\\MasterConversation"

MasterTutorialConversation = Create (State, 
{
	sStateName = "MasterTutorialConversation",
})

function MasterTutorialConversation:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Call the member function StartConversation
	self:StartConversation ()
end

function MasterTutorialConversation:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Make sure both NPCs are still alive
	if self.tNPC1:IsAlive () and self.tNPC2:IsAlive () then

		-- Call the member function StartConversation
		self:StartConversation ()

	end

end

function MasterTutorialConversation:StartConversation ()

	-- Set NPCs to use the MasterConversation state
	-- It is assumed that the pointers self.tNPC1 and self.tNPC2
	-- will be initialised when the state is pushed onto the stack

	self.tNPC1:SetState (Create (MasterConversation,
	{
		tTarget = self.tNPC2,
		bTalkFirst = true,
	}))

	self.tNPC2:SetState (Create (MasterConversation,
	{
		tTarget = self.tNPC1,
		bTalkFirst = false,
	}))

end
