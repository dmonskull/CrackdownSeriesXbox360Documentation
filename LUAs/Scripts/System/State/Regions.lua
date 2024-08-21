----------------------------------------------------------------------
-- Name: Timers
--	Description: Extends the State class - Keep track of regions, so that
-- we can correctly map tables
-- Owner: Bob
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------
function State:CreateRegion( tRoutes, iPriority, iDemand)
	-- Either create or use the global map of regions
	tRegionMap = tRegionMap or {}
	
	-- Create a new region
	region = NavigationManager.CreateRegion(iPriority, iDemand)
	
	-- Add the route names to the region
	if tRoutes then
		for i in pairs(tRoutes) do
			region:AddRouteName(tRoutes[i])
		end
	end

	return region
end

function State:DestroyRegion( region )
	-- Free the region on the C++ side
	NavigationManager.DestroyRegion(region)
end

function State:RetRegionRoutes( region )	
	-- Create table
	local tRouteNames = {}

	-- Add the region's route names to table
	for i=1, region:RetRouteNameCount() do
		tRouteNames[i] = region:RetRouteName(i-1)
	end

	-- Return the table
	return tRouteNames
end
----------------------------------------------------------------------
-- END OF FILE
----------------------------------------------------------------------