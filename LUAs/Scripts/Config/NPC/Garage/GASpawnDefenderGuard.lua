--------------------------------------------------------------
-- Name:			GASpawnGuard
-- Description:		Spawn a garage guard
-- Author:			Neil C - (c) RTWs 2005 
--------------------------------------------------------------

require "State\\Mission\\Garage\\GarageGuards\\GADefenderGuard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nNormal)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)

	tNPC:SetState (Create (Garage.GarageDefenderGuard, 
	{
		-- some how give each guard a different spawn point
		-- some how get an event to change the boolean in your 
		-- defenderguard state
							
		nIdleViewingDistance = 30,
		nAlertViewingDistance = 100,
		nRadius = 010, 
		sGroupName = "A",
			
		nDefensiveIdleViewingDistance = 100,
		nDefensiveAlertViewingDistance = 100,
		nDefensiveRadius = 5,
	}))

end