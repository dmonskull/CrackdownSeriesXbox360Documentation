require "State\\NPC\\Character\\StreetSoldier"

return function (tStreetSoldier)

	-- Give him a weapon if the gang has some available
	if tMuchachos:RetEquipmentAvailability () > 0.5 then
		tStreetSoldier:AddEquipment ("Riley_Panther")
	end

	tStreetSoldier:SetPersonality (cAIPlayer.Rand (0, 100))
	tStreetSoldier:SetShootingAccuracy (cAIPlayer.Rand (20, 60))
	tStreetSoldier:SetTeamSide (tMuchachos)
	tStreetSoldier:SetState (Create (StreetSoldier,
	{
		bOnSideWalk = true,
	}))

end
