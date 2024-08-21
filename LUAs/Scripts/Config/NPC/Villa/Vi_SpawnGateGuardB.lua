require "State\\Mission\\Villa\\GateGuards\\VillaGateGuard"

return function (tNPC)

	tNPC:AddEquipment ("SMG")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nBrave)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)
	
	tNPC:SetState (Create (Villa.VillaGateGuard,
	{
		nTriggerNo = 2,
		nIdleViewingDistance = 40,
		sTriggerZoneName = "TZ_Vi_MainLndGate01",	-- Trigger zone to defend -- They will share the same trigger zone when we can rotate triggers
		nWarnRadius = 20,	-- This is how close you have to get before they warn you off
		nAttackRadius = 20,	-- This is how far they will follow you for when they attack
		
		bDefensiveGuard = true,
		
	}))

end
