require "State\\NPC\\Character\\StreetSoldier"

return function (tNPC)
	tNPC:SetState (StreetSoldier)
	tNPC:SetGameImportance (eGameImportance.nDefault)
end
