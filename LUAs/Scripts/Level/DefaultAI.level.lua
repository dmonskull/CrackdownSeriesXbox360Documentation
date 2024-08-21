-- Load the global graph first in case there are any script errors
NavigationManager.LoadLogicalGraph("AI\\Default\\global_graph.bin", "GlobalGraph", true)

-- Load all patrol routes (for seed point generation) SVP 24/08/2005
--require "Config\\PatrolRouteNames.lua"
--for i in pairs(ePatrolRouteNames) do
--	local route = NavigationManager.LoadPatrolRoute(ePatrolRouteNames[i])
--	assert(route)
--end

require "State\\World\\World"

local tAiManager = cAiManager.RetAiManager()
tAiManager:SetState (World)
