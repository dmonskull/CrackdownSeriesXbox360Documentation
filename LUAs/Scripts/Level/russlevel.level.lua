-- Load the global graph
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)

require "State\\World\\RussWorld"

local tAiManager = cAiManager.RetAiManager()
tAiManager:SetState (RussWorld)