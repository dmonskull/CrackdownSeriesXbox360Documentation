----------------------------------------------------------------------
-- Name: Animation IDs
--	Description: IDs for generic animations - we are supposed to be getting
-- a different system for animations but until we do we're stuck with this
-- Owner: Nathan, Paul
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


require "System\\ReadOnly"

eFullBodyAnimationID = CreateReadOnly
{
	nBackOff = 16001,									-- CA016_AITEST_001_maleAI
	nUpYours = 16002,									-- CA016_AITEST_002_maleAI
	nCower = 16022,									-- CA016_AITEST_022_maleAI
	nCowerToIdle = 16023,								-- CA016_AITEST_023_maleAI
	nHarass = 16005,									-- CA016_AITEST_005_maleAI
	nTaunt1 = 16006,									-- CA016_AITEST_006_maleAI
	nTaunt2 = 16007,									-- CA016_AITEST_007_maleAI
	nTaunt3 = 16008,									-- CA016_AITEST_008_maleAI
	nTaunt4 = 16009,									-- CA016_AITEST_009_maleAI
	nTaunt5 = 16010,									-- CA016_AITEST_010_maleAI
	nIdle1 = 16011,									-- CA016_AITEST_011_maleAI
	nIdle2 = 16012,									-- CA016_AITEST_012_maleAI
	nIdle3 = 16013,									-- CA016_AITEST_013_maleAI
	nIdle4 = 16014,									-- CA016_AITEST_014_maleAI
	nBeckon = 16015,									-- CA016_AITEST_015_maleAI
	nVictory = 16016,									-- CA016_AITEST_016_maleAI
	nCockWeapon = 16017,								-- CA016_AITEST_017_maleAI
	nGiveUp = 16018,									-- CA016_AITEST_018_maleAI
	nPanicFreeze1 = 16019,								-- CA016_AITEST_019_maleAI
	nPanicFreeze2 = 16020,								-- CA016_AITEST_020_maleAI
	nPanicFreeze3 = 16021,								-- CA016_AITEST_021_maleAI
	nPeerOverEdge = 22201,								-- CA022_AITEST_201_maleAI
	nPeerForwardsLeftAndRight = 22202,						-- CA022_AITEST_202_maleAI
	nLookLeftAndRight = 22203,							-- CA022_AITEST_203_maleAI
	nYawn = 22205,									-- CA022_AITEST_205_maleAI
	nRewardInformant = 16024,							-- CA016_AITEST_024_maleAI
	nLookAround = 16025,								-- CA016_AITEST_025_maleAI
	nThank = 16026,									-- CA016_AITEST_026_maleAI
	nIdleToCower = 16027,								-- CA016_AITEST_027_maleAI
	nPunishInformant = 16028,							-- CA016_AITEST_028_maleAI
	nCrowdCheer3 = 27010,								-- CA027_generic_010_maleAI 
	nDance1 = 27011,									-- CA027_generic_011_maleAI
	nDrinking = 27012,									-- CA027_generic-bottle_012_maleAI
	nSpeechAnimViolettaVariation1 = 27039,				-- CA027_boss_039_maleAI
	nRecruiter = 27068,									-- CA027_recruiter_068_maleAI
	nGenericNoNormalStandTalk = 28001,					-- CA028_guard_001_maleAI
}

eUpperBodyAnimationID = CreateReadOnly
{
	nFistFight = 16001,								-- SEG016_AITEST_001_maleAI
	nPanic = 16002,									-- SEG016_AITEST_002_maleAI
	nBackOff = 16003,									-- SEG016_AITEST_003_maleAI
	nSignalAttack1HandGun = 23101,						-- SEG023_AITEST_101_maleAI
	nSignalAttack2HandGun = 23202,						-- SEG023_AITEST_202_maleAI
	nStandingListening = 28003,							-- SEG028_generic_003_maleAI 
	nNormalStandTalk1 = 28005,							-- SEG028_generic_005_maleAI
	nBossNormalStandShoutAndGestureOrdersVariation1 = 28011,				-- SEG028_boss_011_maleAI
}
