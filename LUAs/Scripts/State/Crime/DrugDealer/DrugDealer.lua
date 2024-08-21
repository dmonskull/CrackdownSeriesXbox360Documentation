----------------------------------------------------------------------
-- Name: DrugDealer State
--	Description: A drug dealer and bodyguards hang out
-- Owner: Ed
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\Team\\GangsterTeam\\GangsterTeam"
require "State\\NPC\\Character\\Pedestrian"
require "State\\NPC\\Character\\StreetSoldier"
require "State\\Crime\\DrugDealer\\PreCrime"
require "State\\Crime\\DrugDealer\\Crime"
require "State\\Crime\\DrugDealer\\Reset"
--require "State\\Crime\\DrugDealer\\HarassEnemy"
--require "State\\Crime\\DrugDealer\\AttackEnemy"

namespace ("DrugDealer")

-- maximum numbr of bodyguards ib this crime is 4
DrugDealer = Create (State,
{
	sStateName = "DrugDealer",
	sSpawnPointName = "DrugDealer",
	sTriggerZoneName = "DealAITriggerZone",	
	nMaxBodyGuards = 2,
})

function DrugDealer:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Get the position of the spawn point and make this the focal point of the mission
	local tSpawnPoint = cInfo.FindInfoByName (self.sSpawnPointName)
	assert (tSpawnPoint)
	
	self.tHost:SetPosition (tSpawnPoint:RetPosition ())
	
	-- Spawn the actual drug dealer
	
	local tDealer = cAIPlayer.SpawnNPC  ("AIStreetSoldier5",tSpawnPoint:RetPosition ())
	tDealer.tMainWeapon = tDealer:AddEquipment ("M16")	
	self.tDealer = tDealer

	local vPos = tSpawnPoint:RetPosition ()
	local nRandX = cAIPlayer.Rand (1,2)
	local nRandZ = cAIPlayer.Rand (1,2)						
	local vAdd = MakeVec3 (nRandX, 0, nRandZ)
	local vNewPos = VecAdd (vPos, vAdd)
		
	self.vDealerFacePoint = AILib.RetNearestVertexPosition (vNewPos)
	
	-- Initialise arrays
	self.atBodyGuard = {}

	self.avSpawnPoints = {}
	self.avFacePoints = {}
	
	self.anBodyGuardEventID = {}

	-- Generate array of spawn positions
	--self:GenerateSpawnPoints (self.nMaxGangMembers)

	for i=1, self.nMaxBodyGuards do

		-- Create random start point for first bodyguard near dealer		
		local vPos = tSpawnPoint:RetPosition ()
		
		self.avFacePoints[i] = vPos
		
--		if i == 1 then 		
--		
--			local nRandX = cAIPlayer.Rand (-10,-5)
--			local nRandZ = cAIPlayer.Rand (-10,-5)				
--			
--		end			
--
--		if i == 2 then 		
--		
--			local nRandX = cAIPlayer.Rand (5,10)
--			local nRandZ = cAIPlayer.Rand (5,10)				
--			
--		end			
--
--		if i == 3 then 		
--		
--			local nRandX = cAIPlayer.Rand (-10,-5)
--			local nRandZ = cAIPlayer.Rand (5,10)				
--			
--		end			
--
--		if i == 4 then 		
--		
--			local nRandX = cAIPlayer.Rand (5,10)
--			local nRandZ = cAIPlayer.Rand (-10,-5)				
--			
--		end			

		nRandX = cAIPlayer.FRand (6,9)
		local nChance = cAIPlayer.Rand (1,2)
		if nChance == 2 then		
			nRandX = -nRandX
		end
				
		nRandZ = cAIPlayer.Rand (6,9)				
		local nChance = cAIPlayer.Rand (1,2)
		if nChance == 2 then		
			nRandZ = -nRandZ
		end		
	
		local vAdd = MakeVec3 (nRandX, 0, nRandZ)						
		local vNewPos = VecAdd (vPos, vAdd)
					
		-- Find valid ai node near location (need later check to make sure node is not on road or other side of long fence!!!
		local vPosition = AILib.RetNearestVertexPosition (vNewPos)
--		local vPosition = vNewPos
		
		-- Store start pos in Bodyguards array
		self.avSpawnPoints[i] = vPosition
				
		-- Get the prototype name
		local sProtoName = "AIStreetSoldier5" --.. tostring (cAIPlayer.Rand (1, 2))

		-- Spawn the character
		local tBodyGuard = cAIPlayer.SpawnNPC (sProtoName, self.avSpawnPoints[i])
		
		-- Give him a weapon
		tBodyGuard.tMainWeapon = tBodyGuard:AddEquipment ("M16")
				
		-- Add to a team?
--		tBodyGuard:SetTeamSide (tMuchachos)		

		-- Add to array
		self.atBodyGuard[i] = tBodyGuard		
				
--		-- Add him to the group
--		self:OnAddGangMember (tGangMember)
		self.anBodyGuardEventID[i] = self:Subscribe (eEventType.AIE_CUSTOM, tBodyGuard)
	end
			
	-- Go into the pre-crime state (START THE CRIME SEQUENCE)
	self:PushState (Create (PreCrime, {}))
		
--
--	-- Subscribe to grenade sound events occuring the vicinity of the mission
--	-- TODO - if a grenade lands near them when they are chasing a pedestrian they won't notice!
--	self.nGrenadeSoundID = self:Subscribe (eEventType.AIE_GRENADE_SOUND, nil)
--	self.nZoneAIPlayerID = self:Subscribe (eEventType.AIE_ZONE_AIPLAYER, self:RetTriggerZone ())

end


function DrugDealer:OnActiveStateFinished ()

	-- Find out what stage the crime is at  - the sequence is PreCrime -> Crime -> Reset the it loops round
	local tState = self:RetActiveState ()
	
	-- Hack of some kind - see Nathan
	if not tState then
	
		return true
		
	-- Note: The Crime stage is triggered by the apperance of a suitable buyer character (grabbed during the PreCrime
	-- stage.
	
		
	-- The Crime stage has just fnshed so move on to the reset stage
	elseif tState:IsA (Crime) then
	
		self:ChangeState (Create (Reset, {}))
		return true		
		
	-- The Reset stage is finished so no loop back round to the PreCrime stage so the crime can start again
	elseif tState:IsA (Reset) then
	
		self:ChangeState (Create (PreCrime, {}))
		return true
		
	end
	
	-- Call parent
	return State.OnActiveStateFinished (self)

end

-- A suitable buyer has has entered the trigger zone - so lets move to the Crime stage
function DrugDealer:OnDetectedPedestrian (tPedestrian)
	
	-- Go into the Crime state
	self:ChangeState (Create (Crime, 
	{
		tBuyer = tPedestrian,
		tDealer = self.tDealer,
		atBodyGuard = self.atBodyGuard
	}))

end

-- This function is used to return the number of currently active bodyguards
function DrugDealer:RetNumBodyGuards ()
	return table.getn (self.atBodyGuard)
end

-- Return a pointer to the trigger zone
function DrugDealer:RetTriggerZone ()
	local tZoneManager = cZoneManager.RetZoneManager ()
	assert (tZoneManager)

	local tTriggerZone = tZoneManager:RetNamedAITriggerZone (self.sTriggerZoneName)
	assert (tTriggerZone)

	return tTriggerZone
end
