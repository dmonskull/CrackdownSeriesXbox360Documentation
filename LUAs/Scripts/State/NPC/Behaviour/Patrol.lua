----------------------------------------------------------------------
-- Name: Patrol State
--	Description: Walk around a list of waypoints
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "System\\State"
require "State\\NPC\\Action\\Movement\\PatrolTo"
require "State\\NPC\\Action\\NodeScript\\RunNodeScript"

Patrol = Create (State,
{
	sStateName = "Patrol",
	nWayPointIncrement = 1,
	nCurrentWaypoint = 0,
	nCurrentRoute = 1,	
	nRouteIncrement = 1,	
	bRandomRoute = nil, -- When we reach the end of a route do we select one at random or move to the next
	tPatrolRouteNames = nil, -- An empty table of patrol route names to load
	tPatrolRoutes = nil, -- The actual loaded patrol routes	
	bOnRoute = false,
	bRandomNode = false, -- select random nodes on the route
	tRegionChange = nil, -- Have we already been told to change region?
	nSelectionMode = ePatrolRouteSelection.nNoRouteSelection, -- If we have multiple routes to patrol how do we decide what to do
	--[[nStateInteruptTimerID = nil,
	bPerformWaypointScripts = true,--]]
	nMovementType = eMovementType.nWalk , -- How the character moves around the patrol route
	nCharacterState = eCharacterStates.nPatrol,	-- Animation and speed profile to use
})

function Patrol:OnEnter ()
	-- Call parent
	State.OnEnter (self)

	-- Create the table for the loaded patrol routes
	self.tPatrolRoutes = {}

	-- Remember our characters previous state
	self.nPreviousCharacterState = self.tHost:RetCharacterState ()

	if self.tRegionChange then
	
		-- We have been told either by a child or from previously to start on this route
		-- Lets do so without further ado
		self:Emit( self.tHost:RetName() .. "is entering the patrol state and is being given a Region to patrol" )
		self:StartInNewRegion (self.tRegionChange)
		
	elseif self.tPatrolRouteNames ~= nil then
	
		-- Load the routes if we have them
		self:LoadPatrolRoutes(self.tPatrolRouteNames)
		
		-- Walk to the nearest waypoint
		self:GoToNearestWayPoint ()
		
		-- Assume we start on route
		self:ChangeRoute(1)	
	
	end

	-- Make sure we use the correct animation profile
	self.tHost:SetCharacterState (self.nCharacterState)

	-- Subscribe to events
	self.nChangeRegionEvent = self:Subscribe (eEventType.AIE_MISSIONDIST_CHANGE_REGION, self.tHost)	
end

function Patrol:OnExit ()
	-- Call parent
	State.OnExit (self)

	-- Use default animation profile
	self.tHost:SetCharacterState (self.nPreviousCharacterState)

	-- We may be going off route
	self:SetOnRoute (false)

	-- Unload the routes to free the memory
	self:UnloadPatrolRoutes (self.tPatrolRoutes)
end

function Patrol:OnPause ()
	-- Stop walking to whatever waypoint we were walking to
	self:ClearStack ()

	-- Use default animation profile
	self.tHost:SetCharacterState (self.nPreviousCharacterState)

	-- We may be going off route
	self:SetOnRoute (false)
	
	-- Call parent
	State.OnPause (self)
end

function Patrol:OnResume ()
	-- Call parent
	State.OnResume (self)

	-- Make sure we use the correct animation profile
	self.tHost:SetCharacterState (self.nCharacterState)


	-- Walk to the nearest waypoint
	self:SetOnRoute(true)
	self:GoToNearestWayPoint ()
end

function Patrol:OnEvent (tEvent)

	-- If we are told to change regions, do so.
	if tEvent:HasID (self.nChangeRegionEvent) then	
		self:Emit(self.tHost:RetName() .. " has received a region change event")
		self:StartInNewRegion( tEvent:RetRegion() )
		return true
	end

	-- Call parent
	return State.OnEvent (self, tEvent)
end

function Patrol:OnActiveStateFinished ()	
	-- The animation profile gets reset when the NPC becomes physical. This is 
	-- causing the NPCs to reert to their base profile as soon as they are 
	-- spawned. The temporary fix is to force the profile to the correct one 
	-- as early as possible. This seems like the most sensible place to do this.
	-- After m17 the profile code should change so that any profile changes are 
	-- not lost when the character becomes physical, and this can be removed
	-- pkg (27/8/05)
	self.tHost:SetCharacterState (self.nCharacterState)

	if self:IsInState (PatrolTo) then

		local tCurrentRoute = self.tPatrolRoutes[self.nCurrentRoute]

		self:Emit(self.tHost:RetName() .. " is running node script on route " .. tostring(self.nCurrentRoute) .. " at waypoint " .. tostring(self.nCurrentWaypoint))
		self:Emit("Route has " .. tostring(tCurrentRoute:RetSize()) .. " nodes")

		local tNodeProperties = 
		{
			sScriptName = tCurrentRoute:RetNodeScriptName (self.nCurrentWaypoint),
			vPosition = tCurrentRoute:RetNodePosition (self.nCurrentWaypoint),
			vDirection = tCurrentRoute:RetNodeDirection (self.nCurrentWaypoint),
			nDuration = tCurrentRoute:RetNodeDuration (self.nCurrentWaypoint),
			nRadius = tCurrentRoute:RetNodeRadius (self.nCurrentWaypoint),
			nFOV = tCurrentRoute:RetNodeFOV (self.nCurrentWaypoint),
		}

		self:ChangeState (Create (RunNodeScript,
		{
			tNodeProperties = tNodeProperties,
		}))
		return true

	elseif self:IsInState (RunNodeScript) then

		self:PopState ()
		self:GoToNextWayPoint ()
		return true

	end
	
	-- We didn't handle the state change ourselves, so lets see if the parent wants it
	return State.OnActiveStateFinished()
end

function Patrol:GoToNearestWayPoint ()
	-- Go to nearest waypoint
	self:SetNearestWayPoint()
	self:GoToWayPoint ()
end

function Patrol:SetNearestWayPoint()
	self.nCurrentWaypoint = self.tPatrolRoutes[self.nCurrentRoute]:RetNearestNode (self.tHost:RetPosition ())
end


function Patrol:SelectRandomPatrolRoute()
	--Remove from the old route
	self:SetOnRoute(false) 

	-- Store the previous route so we can see if we need to reverse along it
	local previousRoute = self.nCurrentRoute
	
	-- Randomly select a new route
	self.nCurrentRoute = math.random( table.getn(self.tPatrolRoutes) )

	-- And place the character on that new route
	self:SetOnRoute(true)	

	-- Either restart on the current route, or move to the nearest waypoint on the new route
	if previousRoute == self.nCurrentRoute then
		self:RestartOnCurrentRoute()
	else
		-- Find the nearest waypoint on this new route and start patroling again
		self:GoToNearestWayPoint()
	end	
end

function Patrol:RestartOnCurrentRoute()
	if self.tPatrolRoutes[self.nCurrentRoute]:RetLooping() then
		-- Loop back to beginning of route
		self.nCurrentWaypoint = 0
		self.nWayPointIncrement = 1
	else
		-- Reverse back on route
		self.nWayPointIncrement = self.nWayPointIncrement * -1
		self.nCurrentWaypoint = self.nCurrentWaypoint + (self.nWayPointIncrement * 2)
	end
	self:GoToWayPoint ()
end

function Patrol:IncrementPatrolRoute()
	-- Store a copy of the current route
	local newRoute = self.nCurrentRoute + self.nRouteIncrement

	-- Have we reached the end of our routes?
	if newRoute == ( table.getn( self.tPatrolRoutes ) + 1 )  or newRoute == 0 then
	-- If the route that we are on is considered to be non-looping then we will just revert along it
	-- and change the direction we increment the routes
		if (newRoute ~= 0) and self.tPatrolRoutes[self.nCurrentRoute]:RetLooping() then
			--self.nCurrentRoute = 1
			self:ChangeRoute(1)
			self.nRouteIncrement = 1
			self.nCurrentWaypoint = 0
			self.nWayPointIncrement = 1
		else
			self.nRouteIncrement = self.nRouteIncrement * -1
			self:RestartOnCurrentRoute()		
		end
	else
		self:ChangeRoute( newRoute )

		-- We are starting on a new route
		self:GoToNearestWayPoint()
	end
end

function Patrol:GoToNextWayPoint ()

	-- If we have more than one waypoint we pick a new one, otherwise we just sit here
	if self.tPatrolRoutes[self.nCurrentRoute]:RetSize() ~= 1 then

		-- Pick waypoint randomly if this is specified
		if self.bRandomNode then
			
			local nMaxNodes = self.tPatrolRoutes[self.nCurrentRoute]:RetSize()
			local nRand = cAIPlayer.Rand (0,nMaxNodes-1)
			
			self.nCurrentWaypoint = nRand
			
			self:GoToWayPoint ()
		
		else

			-- Increment waypoint
			self.nCurrentWaypoint = self.nCurrentWaypoint + self.nWayPointIncrement
		
			-- See if it's time to loop back to first waypoint
			if self.nCurrentWaypoint == self.tPatrolRoutes[self.nCurrentRoute]:RetSize() or self.nCurrentWaypoint == -1 then
				-- If we have multiple routes, either increment the route or reverse it				
				if table.getn( self.tPatrolRoutes ) ~= 1 then
					if self.nSelectionMode == ePatrolRouteSelection.nIncremental then
						self:IncrementPatrolRoute()
					elseif self.nSelectionMode == ePatrolRouteSelection.nRandom then
						self:SelectRandomPatrolRoute()
					elseif self.nSelectionMode == ePatrolRouteSelection.nNoRouteSelection then
						self:RestartOnCurrentRoute()
					end
				else
					-- Only the one route, so we have to restart upon it
					self:RestartOnCurrentRoute()
				end
			else
				self:GoToWayPoint ()
			end

		end

	end
end

function Patrol:GoToWayPoint ()
	-- Just some checks to make sure that everything makes sense
	assert(self.nCurrentRoute ~= 0)
	assert(self.nCurrentRoute <= table.getn( self.tPatrolRoutes ) )

	assert(self.nCurrentWaypoint ~= -1)
	if (self.nCurrentWaypoint > self.tPatrolRoutes[self.nCurrentRoute]:RetSize()  ) then
		self:Emit("Waypoint greater than number of node, setting to nearest")
		self:SetNearestWayPoint()
	end

	-- Get the current waypoint position
	local vWayPointPosition = self.tPatrolRoutes[self.nCurrentRoute]:RetNodePosition (self.nCurrentWaypoint)

	-- Go to the waypoint
	self:PushState (Create (PatrolTo,
	{
		vDestination = vWayPointPosition,
		nMovementType = self.nMovementType,
	}))
end

function Patrol:ChangeRoute( iNewRoute)
	-- Make sure we come off of the old route
	self:Emit("Current route is " .. tostring(self.nCurrentRoute) .. " and is going to become " .. tostring(iNewRoute) )	

	if self.tPatrolRoutes[self.nCurrentRoute] then
		self:SetOnRoute(false)
	end
	
	self.nCurrentRoute = iNewRoute

	if self.tPatrolRoutes[self.nCurrentRoute] then
		self:SetOnRoute(true)
	end
end

function Patrol:SetOnRoute (bNewOnRoute)
	--local routeInfo = "AI " .. tostring(self.tHost) .. " being " .. tostring(bNewOnRoute) .. " on " .. self.tPatrolRoutes[self.nCurrentRoute]:RetName()
	--self:Emit(routeInfo)
	
	--if self.bOnRoute ~= bNewOnRoute then
		self.bOnRoute = bNewOnRoute

		-- If on route then defended position is my current position
		if self.bOnRoute then
			self.tHost:SetGuardObject (self.tHost)
		else
			self.tHost:SetGuardObject (nil)
		end

		if self.tPatrolRoutes[self.nCurrentRoute] then
		if(self.bOnRoute) then
			self.tPatrolRoutes[self.nCurrentRoute]:AddObjectToRoute(self.tHost)
		else
			--assert( self.tPatrolRoutes[self.nCurrentRoute]:IsObjectUsingRoute(self.tHost) )
			self.tPatrolRoutes[self.nCurrentRoute]:RemoveObjectFromRoute(self.tHost)
		end
		end
	--end
end

function Patrol:LoadPatrolRoutes(tRoutesToLoad)
	-- Load patrol routes
	for i in pairs(tRoutesToLoad) do
		self.tPatrolRoutes[i] = NavigationManager.LoadPatrolRoute(tRoutesToLoad[i])
		assert(tRoutesToLoad[i])
		assert(self.tPatrolRoutes[i]:RetSize() > 0)
	end
end

function Patrol:UnloadPatrolRoutes(tRoutesToUnLoad)
	if ( table.getn(tRoutesToUnLoad) ~= 0 ) then
		-- Make sure we remove ourselves from the route if we are on it
		self:SetOnRoute(false)
		
		-- Free any routes that we may of loaded
		for i in pairs(tRoutesToUnLoad) do
			NavigationManager.UnloadPatrolRoute(tRoutesToUnLoad[i])
			tRoutesToUnLoad[i] = nil
		end
	end
end

function Patrol:StartInNewRegion( tRegion )	
	self:Emit(self.tHost:RetName() .. " Patrol:StartInNewRegion")
	
	-- Unload the current routes
	self:UnloadPatrolRoutes(self.tPatrolRoutes)

	-- Just some more debug information to work out what the hell is going onself:Emit("Trying to load routes from Region " .. tRegion:RetID() )
	
	-- Set up the new routes
	self.tPatrolRouteNames = self:RetRegionRoutes( tRegion )self:Emit("self.tPatrolRouteNames = " .. tostring(self.tPatrolRouteNames) )
		
	-- Load this set of routes
	self:LoadPatrolRoutes(self.tPatrolRouteNames)self:Emit("self.tPatrolRoutes = " .. tostring(self.tPatrolRoutes) )

	-- If we have some loaded routes, go and use them otherwise we'll print up an error
	if table.getn(self.tPatrolRoutes) then
		-- List the available routes... and the number of people on each	
		for i in pairs(self.tPatrolRoutes) do			
			self:Emit( "Route " .. tostring(i) .. " ".. self.tPatrolRoutes[i]:RetName() .. " has " .. tostring(self.tPatrolRoutes[i]:RetNumberOfObjects() ) )
		end

		-- Now we have to decide which route to actually use...
		if self.bRandomRoute then
			-- Randomly select one of the routes	
			if table.getn(self.tPatrolRoutes) then
				self:ChangeRoute( math.random( table.getn(self.tPatrolRoutes) ) )
			end
		else
			-- Otherwise try and find a route with the least number of people on it
			local leastBusyRouteCount = self.tPatrolRoutes[1]:RetNumberOfObjects()
			local leastBusyRoute = 1
			for i in pairs(self.tPatrolRoutes) do			
				if ( self.tPatrolRoutes[i]:RetNumberOfObjects() < leastBusyRouteCount ) then	
					leastBusyRoute = i					
				end	
			end		
			self:ChangeRoute( leastBusyRoute )
		end

		self:Emit( self.tHost:RetName() .. " being set on route " .. self.tPatrolRoutes[self.nCurrentRoute]:RetName() )
		self.nRouteIncrement = 1
	
		-- If the NPC is currently patrolling then pop that state and change routes now, 
		-- otherwise we let the current state finish and the npc will _then_ go to the next nodeself:Emit(self.tHost:RetDebugString())
		--[[while self:IsInState(Patrol) ~= true do
			self:PopState()
		end--]]
		self:ClearStack()
		self:Emit(self.tHost:RetDebugString())
		self:GoToNearestWayPoint()
		self:Emit(self.tHost:RetDebugString())
	else 
		self:Emit("ERROR - Didn't appear to load routes for region " .. tRegion:RetID() )
	end
end
