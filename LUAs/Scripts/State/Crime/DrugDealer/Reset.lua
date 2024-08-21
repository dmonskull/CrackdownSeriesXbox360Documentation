----------------------------------------------------------------------
-- Name: Reset State
--	Description: The gang members walk back to their original positions
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Crime\\DrugDealer\\WalkBackToSpawnPoint"

namespace ("DrugDealer")

Reset = Create (State,
{
	sStateName = "Reset",
})


function Reset:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Make all bodyguards head back to their start positions
	
	self.nNumBodyGuards = self.tParent.nMaxBodyGuards	
	
	for i = 1, self.nNumBodyGuards do
					
		self.tParent.atBodyGuard[i]:SetState (Create (WalkBackToSpawnPoint,		
		{
			vDestination = self.tParent.avSpawnPoints[i],
			nMovementType = eMovementType.nWalk,
		}))
	end
	
	if self.nNumBodyGuards == 0 then
	
		self:Finish ()
	end
		
end

function Reset:OnEvent (tEvent)

	for i = 1, self.nNumBodyGuards do

		if tEvent:HasID (self.tParent.anBodyGuardEventID[i]) and tEvent:HasCustomEventID ("ReachedSpawnPoint") then

			-- Count the gang members who have reached their spawn points
			local n=0

			for j = 1, self.nNumBodyGuards do

				if self.tParent.atBodyGuard[j]:RetState ():HasReachedSpawnPoint () then

					n = n + 1

				end
			end

			-- If they have all reached their spawn points then finish the state
			if n == self.nNumBodyGuards then


				self:Finish ()
			end
			return true		
		end
		
	end
	
	-- Call parent
	return State.OnEvent (self, tEvent)

end
