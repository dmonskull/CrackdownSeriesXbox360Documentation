----------------------------------------------------------------------
-- Name: PreCrime State
--	Description: The gang members stand around waiting for a pedestrian
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Crime\\DrugDealer\\BodyGuard"

namespace ("DrugDealer")

PreCrime = Create (State,
{
	sStateName = "PreCrime",
})

function PreCrime:OnEnter ()
	-- Call parent
	State.OnEnter (self)
	

	self.nNumBodyGuards = self.tParent.nMaxBodyGuards
	
	for i = 1, self.nNumBodyGuards do
	
	
		self.tParent.atBodyGuard[i]:SetState (Create (BodyGuard,
		{
			vFacePoint = self.tParent.avFacePoints[i],
		}))
	end	
	
	self.tParent.tDealer:SetState (Create (BodyGuard,
		{
				vFacePoint = self.tParent.vDealerFacePoint,
		}))
	
	
	
	
	
	
	
		
	-- Subscribe to events
	self.nZoneAIPlayerID = self:Subscribe (eEventType.AIE_ZONE_AIPLAYER, self.tParent:RetTriggerZone ())
	
	
	
	
	
	
	
		
end

function PreCrime:OnEvent (tEvent)

	-- Some AI player entered the trigger zone
	if tEvent:HasID (self.nZoneAIPlayerID) then

		if tEvent:IsEntering () then			

			-- Are they a pedestrian?
			local tInstigator = tEvent:RetInstigator ()
			
			if tInstigator:RetState () and 
				tInstigator:RetState ():IsA (Pedestrian) and 
				tInstigator:RetState ():IsAvailable () then			
									
				self.tParent:OnDetectedPedestrian (tInstigator)

			elseif tInstigator:RetState () and 
				tInstigator:RetState ():IsA (StreetSoldier) and 
				tInstigator:RetState ():IsAvailable () then				
				
				self.tParent:OnDetectedPedestrian (tInstigator)

			end

		end
		return true

	end
	
	-- Call parent
	return State.OnEvent (self, tEvent)	
end


