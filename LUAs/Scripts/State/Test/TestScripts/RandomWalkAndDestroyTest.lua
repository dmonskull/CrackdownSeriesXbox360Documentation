----------------------------------------------------------------------
-- Name: RandomWalkAndDestroyTest State
-- Description: Test script to make the player attempt to walk to randomly 
-- selected points in the game world and shoot and destroy any explodable items
-- or gang members that are sighted
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Test\\TestScripts\\RandomWalkTest"
require "State\\Test\\TestScripts\\Behaviours\\MoveAndShoot"

RandomWalkAndDestroyTest = Create (RandomWalkTest,
{
	sStateName = "RandomWalkAndDestroyTest",

	bEnableTargeting = true,
	
	-- List of target names that we are interested in. If any one of these substrings exists in 
	-- a targets prototype name then it is considered a valid target
	asTargetPrototypeNames =
	{
		"AIStreetSoldier",
		"PROP_Barrel_",
	},
})

function RandomWalkAndDestroyTest:OnEnter ()
	-- Call parent
	RandomWalkTest.OnEnter (self)

	-- Initialise internal data
	self.nTargetsAttacked = 0
	self.nTargetsKilled = 0
	self.nTargetsNotKilled = 0
	self.nTargetsLost = 0
	self.nTargetsUnreachable = 0
end


function RandomWalkAndDestroyTest:OnActiveStateFinished ()
	if self:IsInState (MoveAndShoot) then
		-- Did we kill the target?
		local tState = self:RetActiveState ()
		if tState:TargetDied () then
			self:TestStatusMessage ("Target killed")
			self.nTargetsKilled = self.nTargetsKilled + 1
		elseif tState:TargetLost () then
			self:TestStatusMessage ("Target lost")
			self.nTargetsLost = self.nTargetsLost + 1
		elseif tState:TargetUnreachable () then
			self:TestStatusMessage ("Target unreachable ")
			self.nTargetsUnreachable = self.nTargetsUnreachable + 1
		else
			self:TestStatusMessage ("Target not killed")
			self.nTargetsNotKilled = self.nTargetsNotKilled + 1
		end
	
		-- Resume walking towards the last selected point
		self:PopState ()
		self:MoveToPoint (self.nLastSelectedPoint)
		return true
	end
		
	-- Call parent
	return RandomWalkTest.OnActiveStateFinished (self)
end


function RandomWalkAndDestroyTest:OnOutputResults ()
	-- Call parent
	RandomWalkTest.OnOutputResults (self)
	
	self:TestStatusMessage ("Tried to attack " .. tostring (self.nTargetsAttacked) .. " targets")
	self:TestStatusMessage (tostring (self.nTargetsKilled) .. " of those were killed")
	self:TestStatusMessage (tostring (self.nTargetsNotKilled) .. " of those were not killed")
	self:TestStatusMessage (tostring (self.nTargetsLost) .. " of those were lost")
	self:TestStatusMessage (tostring (self.nTargetsUnreachable) .. " of those were unreachable")
end


function RandomWalkAndDestroyTest:OnTargetUpdate (nTargets)
	if not self:IsInState (MoveAndShoot) then
	
		local bTargetFound = false
		
		-- Iterate through all targets, looking for an interesting one
		for nIndex = 1, nTargets do
			local tTarget = self:RetTarget (nIndex)
			local sProtoName = tTarget:RetProtoTypeName ()
			
			-- Check prototype name of each target against list of targets that 
			-- we are interested in blowing up
			for nTargetName = 1, table.getn (self.asTargetPrototypeNames) do
				if string.find (sProtoName, self.asTargetPrototypeNames[nTargetName]) then
					self:TestStatusMessage ("Attacking target " .. sProtoName)
					self:ChangeState (Create (MoveAndShoot,
					{
						tTarget = tTarget,
						nMovementType = eMovementType.nRun,
					}))
					self.nTargetsAttacked = self.nTargetsAttacked + 1
					bTargetFound = true
					break
				end
			end

			if bTargetFound then
				break
			end
			
		end
		
	end
end
