local tTeam1 = cTeamManager.RetTeamWithName ("001_GangWar_Team1")
local tTeam2 = cTeamManager.RetTeamWithName ("001_GangWar_Team2")

--local tAiManager = cAiManager.RetAiManager ()
--local tAiPlayer = tAiManager:RetAiPlayerByName ("Arendt")

AILib.Emit (tTeam1:RetDebugString ())
AILib.Emit (tTeam2:RetDebugString ())
