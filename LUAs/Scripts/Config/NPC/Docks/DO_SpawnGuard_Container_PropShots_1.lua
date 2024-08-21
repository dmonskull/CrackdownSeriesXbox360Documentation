require "State\\Mission\\Docks\\Guards\\Guard_Container_PropShot"

return function (tNPC)

--	tNPC:AddEquipment ("RocketLauncher")
	tNPC:AddEquipment ("SniperRifle")
	tNPC:AddEquipment ("Grenade")
	tNPC:SetTeamSide (tMob)
	tNPC:SetPersonality (ePersonality.nCowardly)
--	tNPC:SetShootingAccuracy (eShootingAccuracy.nGood)
    tNPC:SetShootingAccuracy (100)
	
	tNPC:SetState (Create (Docks.Guard_Container_PropShot,
	{
		nIdleViewingDistance = 100,
		nAlertViewingDistance = 100,
		nRadius = 100,
        sTargetPropShot = "SP_DO_Container_PropShot_1",
        sTriggerPropShot = "TZ_DO_Container_PropShot_1",
	}))
	
end
