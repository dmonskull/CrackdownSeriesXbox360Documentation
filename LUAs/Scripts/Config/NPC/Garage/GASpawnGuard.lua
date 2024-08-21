--------------------------------------------------------------
-- Name:			GASpawnGuard
-- Description:		Spawn a garage guard
-- Author:			Neil C - (c) RTWs 2005 
--------------------------------------------------------------

require "State\\NPC\\Character\\Guard"

return function (tNPC)

	tNPC:AddEquipment ("M16")
	tNPC:SetTeamSide (tMuchachos)
	tNPC:SetPersonality (ePersonality.nNormal)
	tNPC:SetShootingAccuracy (eShootingAccuracy.nNormal)

	tNPC:SetState (Create (Guard, 
	{
		
	}))

end