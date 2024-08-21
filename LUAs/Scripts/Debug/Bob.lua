require "State\\NPC\\Behaviour\\Patrol"

Bob = Create (Patrol,
{
	sStateName = "Bob",
	tPatrolRouteNames = {"GameplayTest\\Route_PJ_TowerBaseLeft"
	,"GameplayTest\\Route_PJ_TowerBaseRight" },	
	bRandomRoute = true,
}
)

function Bob:OnEnter()
	Patrol.OnEnter(self)

	 --local TOD = cTimeOfDay.RetTimeOfDayManager()

-- Create a time of day request
	self.MiddayEvent = self:RequestTimeOfDayNotification(0.5, true)

-- Lets subscribe to the TOD event
	self.nTODEventID = self:Subscribe (eEventType.AIE_TIME_OF_DAY, self.tHost)
end

function Bob:OnEvent(tEvent)
-- Recv the event and do what we want with it
	if tEvent:HasID (self.nTODEventID) then
		if tEvent:HasTodID (self.MiddayEvent) then		
			self.tHost:Speak("Ohh it's Midday")		

			-- As a quick test, get the event back
			local event = self:RetTimeOfDayNotification(self.MiddayEvent)
			assert(event)
			local time = event:RetTime()
		end
		return true
	end
	return Patrol.OnEvent(self, tEvent)
end

function Bob:OnExit()
	Patrol.OnExit(self)	
end


local tom = cAIPlayer.SpawnNPCAtNamedLocation("AIStreetSoldier1", "SP_PJ_TowerBaseLeft")
tom:SetState(Bob)
