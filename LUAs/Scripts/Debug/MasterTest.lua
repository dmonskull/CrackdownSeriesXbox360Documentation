-- Reload the MasterTutorial state (and all the states it requires)
_LOADED = {}
require "State\\Crime\\MasterTutorial\\MasterTutorial"

-- Get pointers to the NPCs from the old state
local tNPC1 = MasterTutorialCrime:RetState ().tNPC1
local tNPC2 = MasterTutorialCrime:RetState ().tNPC2

-- Now set the state to Tutorial.  This deletes the old Tutorial
-- state and creates a one, only the new one is the one that has
-- just been reloaded
MasterTutorialCrime:SetState (MasterTutorial)

-- Delete the NPCs that were spawned by the old state
AILib.DeleteGameObject (tNPC1)
AILib.DeleteGameObject (tNPC2)
