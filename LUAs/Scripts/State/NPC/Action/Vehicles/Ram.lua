----------------------------------------------------------------------
-- Name: Ram 
--	Description: Drive to a particular position, chase and Ram
-- Owner: HS
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Ram = Create (TargetState, 
{
	sStateName = "Ram",
	nEndBehaviour = 0,			-- Corrresponds to the enum EBEH_STOP in C++, see cDriveToAgent.h
	nSpeed = 0.5,
	bFullPhysics = false,
	bSlowDownAvoidance = false,
	bRespectLights = false,
	bMatchSpeed = false,
	bSenseOnGrid	= true,
	bCompeteForOneLane = false,
	nStopRadius = 6,
	bSuccess = false,
})

function Ram:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.nSpeed)
	--assert(self.bWithPathFind)

	-- Subscribe to reached destination event
	self.nReachedDestinationID = self:Subscribe(eEventType.AIE_REACHED_DESTINATION, self.tHost, 0)

	-- Go to destination
	self:OnResume ()
end

-- Over-ride this to set the correct 'move' brainstate
function Ram:OnResume ()
	-- Call parent
	TargetState.OnResume (self)

		-- Now pass these to the fns in C++ 
	self.tHost:SetDriveStyles(self.bSlowDownAvoidance, 
		self.bRespectLights,
		self.bMatchSpeed, 
		self.bSenseOnGrid, 
		self.bCompeteForOneLane,
		false, 
		false)

	self.tHost:SetDriveParrams(self.nEndBehaviour,
		self.nSpeed, 
		self.bFullPhysics,
		self.nStopRadius)

end

function Ram:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Ram:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Ram:OnEvent (tEvent)

	-- Reached destination
	if tEvent:HasID (self.nReachedDestinationID) then
	
		self.bSuccess = tEvent:RetSuccess ()
		self:Finish ()
		return true
	
	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Ram:Success ()
	return self.bSuccess
end
