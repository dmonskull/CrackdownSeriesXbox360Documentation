require "Pedestrian"
require "StreetSoldier"
require "Guard"

gfxtest = Create (Behaviour,
{
	-- Define member variables
	NPCs = { nil, nil, nil }
})

function gfxtest:OnEnter ()
	-- Call parent
	Behaviour.OnEnter (self)

	-- Spawn NPCs
	--self.NPCs[1] = cAIPlayer.SpawnNPC("AI Civilian", 1169,31,-1213)
	--self.NPCs[1]:SetBehaviour(Pedestrian)

	--self.NPCs[2] = cAIPlayer.SpawnNPC("AI Street Soldier Machine Gun", -1211.0, 30.0, 1435.0)
	--self.NPCs[2]:SetBehaviour(StreetSoldier)

	--self.NPCs[3] = cAIPlayer.SpawnNPC("AI Street Soldier Machine Gun", -1200.0, 31.0, 1400.0)
	--self.GuardBehaviour = Create (Guard, {PatrolRouteName="M12\\patrol_route", AttentionRadius=30, ChaseDelta=10, FleeDamageThreshold=20})
	--self.NPCs[3]:SetBehaviour(self.GuardBehaviour)
end


function gfxtest:OnEvent (event)
	-- Call parent
	Behaviour.OnEvent (self, event)
end
