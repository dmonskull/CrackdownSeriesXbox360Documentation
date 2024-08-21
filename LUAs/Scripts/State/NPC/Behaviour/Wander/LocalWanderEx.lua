----------------------------------------------------------------------
-- Name: LocalWanderEx State
-- Description: Wander around the local graph, occasionally executing a nodescript
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Wander\\LocalWander"
require "State\\NPC\\Action\\NodeScript\\RunNodeScript"

LocalWanderEx = Create (State, 
{
	sStateName = "LocalWanderEx",
	nMinNodeScriptTime = 5,			-- Minimum time between executing a node script
	nMaxNodeScriptTime = 10,		-- Maximum time between executing a node script
	atNodeScripts = nil,			-- Pass in an array of node scripts
	bUseRadius = false,				-- Set to true if you want to stick within a radius
	vCentrePosition = nil,			-- Specify centre of radius
	nRadius = 10,					-- Specify radius
})

function LocalWanderEx:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Subscribe events
	self.nTimerFinishedID = self:Subscribe (eEventType.AIE_TIMER_FINISHED, self.tHost)

	self:PushState (self:CreateLocalWanderState ())
	self:StartTimer ()
end

function LocalWanderEx:OnEvent (tEvent)

	if self.atNodeScripts and tEvent:HasID (self.nTimerFinishedID) and tEvent:HasTimerID (self.nTimerID) then

		-- Run the node script
		self:ChangeState (self:CreateRunNodeScriptState ())
		return true

	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function LocalWanderEx:OnActiveStateFinished ()

	if self:IsInState (RunNodeScript) then

		self:ChangeState (self:CreateLocalWanderState ())
		self:StartTimer ()
		return true

	end

	-- Call parent
	return State.OnActiveStateFinished (self)
end

function LocalWanderEx:StartTimer ()
	-- Start a timer if we have any node scripts
	if self.atNodeScripts then
		local nTime = cAIPlayer.Rand (self.nMinNodeScriptTime, self.nMaxNodeScriptTime)
		self.nTimerID = self:AddTimer (nTime, false)
	end
end

function LocalWanderEx:CreateLocalWanderState ()
	return Create (LocalWander, 
	{
		bUseRadius = self.bUseRadius,
		vCentrePosition = self.vCentrePosition,
		nRadius = self.nRadius,
	})
end

function LocalWanderEx:CreateRunNodeScriptState ()
	-- Get a random node from the list
	local nCurrentNode = cAIPlayer.Rand (1, table.getn (self.atNodeScripts))
	local tNodeProperties = self.atNodeScripts[nCurrentNode]

	-- Default the node script's position and direction to be the NPCs current 
	-- position and direction
	tNodeProperties.vPosition = tNodeProperties.vPosition or self.tHost:RetCentre ()
	tNodeProperties.vDirection = tNodeProperties.vDirection or self.tHost:RetHeadingDirection ()

	return Create (RunNodeScript,
	{
		tNodeProperties = tNodeProperties,
	})
end
