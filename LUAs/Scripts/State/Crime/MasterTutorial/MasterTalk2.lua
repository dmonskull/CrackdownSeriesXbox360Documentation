---------------------------------------------------------------------
-- Name: MasterTalk2 State
-- Description: Talk state for the first NPC
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
---------------------------------------------------------------------

-- Load the state that we want to be derived from
require "State\\Crime\\MasterTutorial\\MasterTalk"

-- Create a state called MasterTalk2 that inherits from MasterTalk
MasterTalk2 = Create (MasterTalk, 
{
	sStateName = "MasterTalk2",
})

-- Over-ride the MasterTalk:SaySomething function
function MasterTalk2:SaySomething ()
	-- Pick a random integer between 1 and 4 inclusive
	local n = cAIPlayer.Rand (1, 4)

	if n == 1 then
		self.tHost:Speak ("You slag.")
	elseif n == 2 then
		self.tHost:Speak ("You slag!")
	elseif n == 3 then
		self.tHost:Speak ("YOU slag!!!")
	elseif n == 4 then
		self.tHost:Speak ("You complete and utter slag!")
	end
end
