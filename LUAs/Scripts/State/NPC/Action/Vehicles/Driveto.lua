----------------------------------------------------------------------
-- Name: Driveto 
--	Description: Drive to a particular position
-- Owner: HS
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"

Driveto = Create (TargetState, 
{
	sStateName = "Driveto",
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

function Driveto:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Check parameters
	assert (self.nSpeed)
	--assert(self.bWithPathFind)

	-- Subscribe to arrived at destination event
	self.nArrivedID = self:Subscribe(eEventType.AIE_DRIVETOAGENT_ARRIVED, self.tHost)

	-- Go to destination
	self:OnResume ()
end

-- Over-ride this to set the correct 'move' brainstate
function Driveto:OnResume ()
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

function Driveto:OnPause ()
	-- Clean up the brain state
	self.tHost:ClearBrainState ()

	-- Call parent
	TargetState.OnPause (self)
end

function Driveto:OnExit ()
	self:OnPause ()

	-- Call parent
	TargetState.OnExit (self)
end

function Driveto:OnEvent (tEvent)

	-- Arrived at destination
	if tEvent:HasID (self.nArrivedID) then
	
		self.bSuccess = tEvent:HasArrived ()
		self:Finish ()
		return true
	
	end

	-- Call parent
	return TargetState.OnEvent (self, tEvent)
end

function Driveto:Success ()
	return self.bSuccess
end
