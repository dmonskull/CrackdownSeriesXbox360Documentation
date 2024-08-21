----------------------------------------------------------------------
-- Name: WalkBackToSpawnPoint State
--	Description: Walks back to the spawn point and stands there facing it
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Movement\\Move"
require "State\\NPC\\Action\\Turn\\Face"
require "State\\NPC\\Action\\Idle\\Wait"
require "State\\NPC\\Action\\Equipment\\StoreItem"

namespace ("DrugDealer")

WalkBackToSpawnPoint = Create (TargetState,
{
	sStateName = "WalkBackToSpawnPoint",
})

--BackInPosition = Create (TargetState,
--{
--	sStateName = "BackInPosition",
--})

function WalkBackToSpawnPoint:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	assert (self.vDestination)
--	assert (self.vFacePoint)	

--	-- Set target to mission spawnpoint (the center of the gang circle)
--	self.tHost:PushTargetPosition (self.vFacePoint)

	--Face the target
	self:PushState (Create (Face, {}))

	-- Walk to spawn position
	self:PushState (Create (Move,
	{
		vDestination = self.vDestination,
		nMovementType = eMovementType.nWalk,
	}))

	local nWaitTime = cAIPlayer.FRand (1,4)

	-- Put away weapon
	self:PushState (Create (StoreItem, {}))
	
	--Wait requisite time	
	self:PushState (Create (Wait,
	{
		nWaitTime = nWaitTime
	}))			

end

--function WalkBackToSpawnPoint:OnExit ()
--	-- Call parent
--	State.OnExit (self)
--	self.tHost:PopTarget ()
--end

function WalkBackToSpawnPoint:OnActiveStateFinished ()
	-- Call parent
	if TargetState.OnActiveStateFinished (self) then

		if self:HasReachedSpawnPoint () then
		
			AILib.Emit ("***** 1 HOME *****")
		
			self.tHost:NotifyCustomEvent ("ReachedSpawnPoint")
		end
		return true

	end
	return false
end

-- Return true if the character has reached his spawn point
function WalkBackToSpawnPoint:HasReachedSpawnPoint ()
	return self:RetActiveState ():IsA (Face)
end
