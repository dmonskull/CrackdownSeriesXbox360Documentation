---------------------------------------------------------------------
-- Name: MasterTalk1 State
-- Description: Talk state for the first NPC
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
---------------------------------------------------------------------

-- Load the state that we want to be derived from
require "State\\Crime\\MasterTutorial\\MasterTalk"

-- Create a state called MasterTalk1 that inherits from MasterTalk
MasterTalk1 = Create (MasterTalk, 
{
	sStateName = "MasterTalk1",
})

-- Over-ride the MasterTalk:SaySomething function
function MasterTalk1:SaySomething ()
	-- Pick a random integer between 1 and 4 inclusive
	local n = cAIPlayer.Rand (1, 4)

	if n == 1 then
		self.tHost:Speak ("You muppet.")
	elseif n == 2 then
		self.tHost:Speak ("You muppet!")
	elseif n == 3 then
		self.tHost:Speak ("You MUPPET!!!")
	elseif n == 4 then
		self.tHost:Speak ("You TOTAL muppet!")
	end
end
