require "State\\NPC\\Character\\GateGuard"

return function (tNPC)

--	tNPC:AddEquipment ("Riley_Panther")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nCowardly)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
	
	tNPC:SetState (Create (GateGuard,
	{
		sTriggerZoneName = "TZ_HH_GateGuardsLower",	-- Trigger zone to defend
		nWarnRadius = 15,	-- This is how close you have to get before they warn you off
		nAttackRadius =15,	-- This is how far they will follow you for when they attack
	}))

end
