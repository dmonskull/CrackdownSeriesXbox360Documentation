----------------------------------------------------------------------
-- Name: Chat State
--	Description: Say something to another character and wait for a reply
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\Action\\Turn\\Face"

Chat = Create (Face, 
{
	sStateName = "Chat",
})

function Chat:OnEnter ()
	-- Call parent
	Face.OnEnter (self)
	
	self.tHost:Speak ("")
end
