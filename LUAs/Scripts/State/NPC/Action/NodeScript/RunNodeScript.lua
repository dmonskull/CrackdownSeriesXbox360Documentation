----------------------------------------------------------------------
-- Name: RunNodeScript State
-- Description: Executes a nodescript
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"

RunNodeScript = Create (State, 
{
	sStateName = "RunNodeScript",
	tNodeProperties = nil,	-- Table containing all the properties of the node
})

function RunNodeScript:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Check parameters
	assert (self.tNodeProperties)

	if self.tNodeProperties.sScriptName and
		self.tNodeProperties.sScriptName ~= "" then
		
		self:Emit (self.tHost:RetName() .. " is attempting to run nodescript " .. self.tNodeProperties.sScriptName)

		-- Yes there is so run the script, which will return a function
		local fFunction = RunScript (self.tNodeProperties.sScriptName .. ".lua")
		assert (fFunction)
		
		-- Now call that function and pass in the npc, the route and the node properties
		if not fFunction (self, self.tNodeProperties) then

			-- The return value tells us whether the script pushed a new state 
			-- onto the stack or not - if it didn't then finish immediately
			self:Finish ()

		end

	else
		self:Finish ()
	end

end

function RunNodeScript:OnActiveStateFinished ()
	self:Finish ()
	return true
end
