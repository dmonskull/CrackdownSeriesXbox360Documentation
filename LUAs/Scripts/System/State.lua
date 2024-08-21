----------------------------------------------------------------------
-- Name: State
--	Description: The base class for an AI state
-- The AI consists of a hierarchy of state machines
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\BaseObject"

State = Create (BaseObject,
{
	sStateName = "State",
	bStateFinished = false,
	bEnableEmits = false,
	bActiveStateLocked = false,
})

-- OnEnter - over-ride this
function State:OnEnter ()
	self.atStack = {}
end

-- OnExit - over-ride this
function State:OnExit ()
	self:ClearStack ()
	self:UnsubscribeAll ()
	self:DeleteAllTimers ()
	self:DeleteAllProximityChecks ()
	self:StopAllTimeOfDayNotifications ()
	self:TermAllTriggerZones ()
	self:DeleteAllMissions ()
	self:DeleteAllAmbientCrimeTypes ()
end

function State:OnEvent (tEvent)
	if self:RetStackSize () > 0 then
		if self:RetActiveState ():OnEvent (tEvent) then
			self:CheckActiveState ()
			return true
		end
	end

	if self:OnNPCTriggerEvent (tEvent) then
		self:CheckActiveState ()
		return true
	end

	-- Have we received a timer event? If so, and the 
	-- timer isn't looping, then we need to remove it
	if self.nStateTimerFinished ~= nil then
		if tEvent:HasID (self.nStateTimerFinished) then
			local TimerID = tEvent:RetTimerID()
			if self.aNonLoopingTimerIDs[TimerID] ~= nil then
				self:DeleteTimer(TimerID)				
			end
			return true
		end
	end

	return false
end

-- IsA function - Overrides the BaseObject IsA function to compare state
-- name variables rather that the pointers to the table objects themselves
-- This means that if the state is reloaded anything that calls IsA on the old
-- state will still return true even though it is a different table
function State:IsA (Object)

	if Object.sStateName and Object.sStateName == self.sStateName then
		return true
	else
		local meta = getmetatable (self)
		
		if meta == nil then
			return false
		else
			if meta.IsA == nil then
				if meta.__index == nil then
					return false
				elseif meta.__index.IsA == nil then
					return false
				else
					return meta.__index:IsA (Object)
				end
			else
				return meta:IsA (Object)
			end
		end
	end
	
end

-- Return a string showing the current state stack hierarchy
function State:RetDebugString ()
	local str = self.sStateName .. " ("
	
	for i=1, self:RetStackSize () - 1 do
		str = str .. self.atStack[i]:RetDebugString () .. ", "
	end

	if self:RetActiveState () then
		str = str .. self:RetActiveState():RetDebugString ()
	end

	str = str .. ")"
	return str
end

function State:OnCompress ()
end

function State:OnUncompress ()
end

-- A per class emit method
function State:Emit(sString)
	assert(self.bEnableEmits ~= nil)
	if self.bEnableEmits == true then
		Emit(sString)
	end
end


require "System\\State\\StateStack"
require "System\\State\\EventSubscriptions"
require "System\\State\\NPCTriggers"
require "System\\State\\Timers"
require "System\\State\\TimeOfDay"
require "System\\State\\ProximityChecks"
require "System\\State\\Regions"
require "System\\State\\TriggerZones"
require "System\\State\\Missions"
require "System\\State\\AmbientCrimes"
