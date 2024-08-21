----------------------------------------------------------------------
-- Name: Enums
-- Description: Tables that correspond to c++ enumerations
-- TODO - All these enums have to be kept up to date manually
-- We might need a better way of doing this... - NJR
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Config\\PatrolRouteNames"
require "Config\\AnimationIDs"
require "Config\\Vocals"
require "Config\\Videos"
require "System\\ReadOnly"

eGameImportance = CreateReadOnly
{
	nCritical = 0,
	nHigh = 1,
	nDefault = 2,
	nLow = 3,
}

eMovementType = CreateReadOnly
{
	nWalk = 0,
	nRun = 1,
	nSprint = 2,
	nLimp = 3,
}

eCharacterStates = CreateReadOnly
{
	nNormal = 0,
	nPatrol = 1,
}

eMovementPriority = CreateReadOnly
{
	nLow = 0,
	nHigh = 1,
}

eSkillSet = CreateReadOnly
{
	nAthletics = 0,
	nDriving = 1,
	nExplosives = 2,
	nFighting = 3,
	nFireArms = 4,
	nGadgets = 5,
}

eEnemyStatus = CreateReadOnly
{
	nActive = 0,
	nLost = 1,
	nDead = 2,
}

eBodyLocation = CreateReadOnly
{
	nTorso =  0,
	nHead = 1,
	nLeftArm = 2,
	nRightArm = 3,
	nLeftLeg = 4,
	nRightLeg = 5,
}

eRelationship = CreateReadOnly
{
	nEnemy = -1,
	nNeutral = 0,
	nFriend = 1,
}

ePersonality = CreateReadOnly
{
	nCowardly = 25,
	nNormal = 50,
	nBrave = 75,
}

eShootingAccuracy = CreateReadOnly
{
	nBad = 25,
	nNormal = 50,
	nGood = 75,
	nExcellent = 100,
}

eMapStatus = CreateReadOnly
{
	nStandard = 0,
	nPatrolling = 1,
	nFleeing = 2,
	nAlerted = 3,
	nAttacking = 4,
}

ePatrolRouteSelection = -- CreateReadOnly
{
	nRandom = 0,
	nNearest = 1,
	nLeastBusy = 2,	
	nIncremental = 3,
	nFirst = 4,
	nNoRouteChange = 5,
}

eRegionData = CreateReadOnly
{
	nSpawnLocation = 0, 	-- E_REGION_DATA_SPAWNLOCATION,
	nSpawnScript = 1, 		-- E_REGION_DATA_SPAWNSCRIPT,
	nDisperseScript = 2, 	-- E_REGION_DATA_DISPERSESCRIPT,
	nPrototype = 3, 		-- E_REGION_DATA_PROTOTYPE,	
}

eTargetInfoFlags = CreateReadOnly
{
	nAlwaysTrack = 1,				-- Always know where the target is whether or not we can see it
	nVisibilityChecks = 2,			-- Perform visibility checks
	nPrimaryFireChecks = 4,			-- Perform primary fire checks
	nSecondaryFireChecks = 8,		-- Perform secondary fire checks
	nThrowChecks = 16,				-- Perform throwing checks
	nCombatTargetingChecks = 32,	-- Perform hand to hand combat checks
	nObjectTargetingChecks = 64,	-- Perform picking up object checks
	nVehicleTargetingChecks = 128,	-- Perform entering and exiting vehicle checks
	nInventoryWeaponChecks = 256,	-- Perform checks for weapons in the inventory that could be used to attack the target
	nAreaWeaponChecks = 512,		-- Perform checks for weapons in the nearby area that could be used to attack the target
}

eEquipmentType = CreateReadOnly
{
	nNone = 0,
	nPrimary = 1,
	nSecondary = 2,
}
