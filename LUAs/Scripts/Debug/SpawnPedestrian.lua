require "Debug\\SpawnInFrontOfPlayer"
require "State\\NPC\\Character\\Pedestrian"

local tNPC = SpawnNPCInFrontOfPlayer ("AIStreetSoldier1")

tNPC:SetPersonality (cAIPlayer.Rand (0, 100))
tNPC:SetShootingAccuracy (eShootingAccuracy.nBad)
tNPC:SetTeamSide (tCivilians)
tNPC:SetState (Pedestrian)
