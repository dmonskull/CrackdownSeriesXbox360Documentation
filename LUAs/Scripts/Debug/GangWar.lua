require "Debug\\SpawnInFrontOfPlayer"
require "State\\Team\\Character\\GangsterTeam"

local nNumMuchachos = 16
local nNumMob = 16

local vCenter = RetPosInFrontOfPlayer (20)

local tMuchachoTeam = cTeamManager.CreateTeam ("TeamMuchacho", tMuchachos, true)
local tMobTeam = cTeamManager.CreateTeam ("TeamMob", tMob, true)

for i=1, nNumMuchachos do

	local vPos = VecAdd (vCenter, MakeVec3 (-2, 0, (i - (nNumMuchachos / 2)) * 5))

	local tNPC = cAIPlayer.SpawnNPC ("AIStreetSoldier1", vPos)
--	tNPC:AddEquipment ("M16")

	tMuchachoTeam:AddEntity (tNPC)

end

for i=1, nNumMob do

	local vPos = VecAdd (vCenter, MakeVec3 (2, 0, (i - (nNumMob / 2)) * 5))

	local tNPC = cAIPlayer.SpawnNPC ("AIStreetSoldier2", vPos)
--	tNPC:AddEquipment ("M16")

	tMobTeam:AddEntity (tNPC)

end

tMuchachoTeam:SetState (GangsterTeam)
tMobTeam:SetState (GangsterTeam)
