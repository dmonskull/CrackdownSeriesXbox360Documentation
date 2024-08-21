require "State\\NPC\\Character\\Guard"
require "System\\State"
require "Debug\\SpawnInFrontOfPlayer"
 
 
--local TOD = cTimeOfDay.RetTimeOfDayManager()
--local CurrentTime = TOD:RetPhase()


--if CurrentTime > 0.5 and CurrentTime < 1.0 then 
 
 AILib.Emit ("This script is running true!")

else  
 AILib.Emit ("This script is running false!")
end

















--Bill = Create (State,
--{
--	sStateName = "Bill",
	--tPatrolRouteNames = {"GameplayTest\\Route_PJ_TowerBaseLeft"
	--,"GameplayTest\\Route_PJ_TowerBaseRight" },	
	--bRandomRoute = true,
--}

---AILib.Emit ("This script is running2!")

 
--local tCar0 = SpawnInFrontOfPlayer ("G1_039_JapaneseCar", nil, 5)
--local tCar1 = SpawnInFrontOfPlayer ("CIV_004_Cabriolet", nil, 15)
--local tCar2 = SpawnInFrontOfPlayer ("CIV_007_HatchBack", nil, 25)
--local tCar3 = SpawnInFrontOfPlayer ("CIV_010_SportsPickup", nil, 30)
--local tCar4 = SpawnInFrontOfPlayer ("CIV_011_SuperMini", nil, 40)
--local tCar5 = SpawnInFrontOfPlayer ("CIV_027_TruckCab", nil, 50) -- crashes
--local tCar6 = SpawnInFrontOfPlayer ("G1_040_PonyCar", nil, 60) -- doesnt spawn
--local tCar7 = SpawnInFrontOfPlayer ("G1_041_MuscleCar", nil, 70) --crashes

 local tNPC = SpawnInFrontOfPlayer ("Civilian1", nil, 5)

--function Bill:OnEnter()
--AILib.Emit ("This script is running3!")
--	local TOD = cTimeOfDay.RetTimeOfDayManager()
--	local CurrentTime = TOD:RetPhase()
--
--	if CurrentTime > 0.001 and < 0.5 then 
--{

--local tSpawnPoint = cInfo.FindInfoByName ("SP_ParkDrugVan")
--assert (tSpawnPoint)
--local tCar = AILib.Spawn("CIV_027_TruckCab", eGameImportance.nDefault, 0,tSpawnPoint:RetPosition ())
--		AILib.Emit ("**************** NIGHTIME")
--} 
 
--	else 
--{
--		AILib.Emit ("**************** not nightime, the club is closed")
--	end
---	return true
--end





 --local tNPC1 = cAIPlayer.SpawnNPCAtNamedLocation ("AIStreetSoldier1", "SP_ParkDrugVan")
--local tSpawnPoint = cInfo.FindInfoByName ("SP_ParkDrugVan")
--assert (tSpawnPoint)
--local tCar = AILib.Spawn("CIV_027_TruckCab", eGameImportance.nDefault, 0,tSpawnPoint:RetPosition ())
 
 --tNPC1:SetTeamSide (tMuchachos)
 --tNPC1:AddEquipment ("M16")
 
-- tNPC1:SetState (Create (Guard, 
 --{
--    tPatrolRouteNames = {"default\\nightclub\\NC_DrGrd1_patrol"},     
-- }))
 
 
 --			local tSpawnPoint = cInfo.FindInfoByName (self:RetSpawnPointName (nIndex))
 --			assert (tSpawnPoint)
 --			local tGang = self:RetGang (nIndex)
--




 
---XUIFrontEnd.VideoPlay("Crackdown_Juan_Outro.bik", false)
 
--local nGangInfluence = tGang:RetInfluence (tSpawnPoint:RetPosition ())