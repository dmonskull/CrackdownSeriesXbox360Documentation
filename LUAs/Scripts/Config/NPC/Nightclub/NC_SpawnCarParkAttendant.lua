require "State\\Mission\\Nightclub\\GateGuards\\NClubCrPrkAttendant"

return function (tNPC)

	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (Nightclub.NCCrPrkAttendant,
	{
		nTriggerNo = 1,
		nMovementType = eMovementType.nRun, 
		
		nIdleViewingDistance = 30,
		nAlertViewingDistance = 100,
		
		sTriggerZoneName = "TZ_NC_CrPrkEntrance",	-- Trigger zone to defend
		nWarnRadius = 15,	-- This is how close you have to get before they warn you off
		nAttackRadius =15,	-- This is how far they will follow you for when they attack
	}))

end


