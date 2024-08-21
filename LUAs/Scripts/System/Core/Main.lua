ThreadTable = {}
NextThreadKey = 1

-- Global initialisaiton
function Init()
	-- Ensure that the random numbers are sync safe version
	math.random = rand
end

function cPopulationInfo:AddPedestrian (Probability, Prototype, Script)
	cPedestrianSpawnCollection.Create (self, Probability, Prototype, Script)
end

function cPopulationInfo:AddDrivenVehicle (Probability, VehiclePrototype, VehicleScript, DriverPrototype, DriverScript, ...)
	cVehicleSpawnCollection.Create (
		self, Probability,
		VehiclePrototype, VehicleScript,
		DriverPrototype, DriverScript)
end

function cPopulationInfo:AddParkedVehicle (Probability, Prototype, Script)
		cVehicleSpawnCollection.Create (self, Probability, Prototype, Script)
end

function RunScript (sFilename)
	local sPath = LUA_PATH

	repeat

		local nIndex = string.find (sPath, ";");

		local sSinglePath = ""
	
		if nIndex then
			sSinglePath = string.sub (sPath, 1, nIndex-1)
		else
			sSinglePath = sPath
		end

		if sSinglePath then
			sSinglePath = string.gsub (sSinglePath, "%?", sFilename)
	
			local chunkScript = loadfile (sSinglePath)
			
			if chunkScript then return chunkScript() end
		end

		if nIndex then
			sPath = string.sub (sPath,nIndex+1, -1)
		else
			sPath = ""
		end

	until string.find (sPath, ".+") == nil

	return nil, string.format ("failed to find file %s at %s", sFilename, LUA_PATH)
end

function OnBeginPlay (sLevelName)
	RunScript (string.format ("Level\\%s.level", sLevelName))
end

function OnEndPlay ()
	MyMission = nil
end

-- Get owner of current thread
CurrentOwner = nil
function GetOwner ()
	return CurrentOwner
end
    
-- Update all threads (coroutines)
function Update()
    for Key in pairs(ThreadTable) do
		CurrentOwner = ThreadTable[Key].Owner
		coroutine.resume(ThreadTable[Key].Thread)
	end
	CurrentOwner = nil
end

-- Global cleanup
function Term()
    ThreadTable = nil
end

-- Returns unnique thread key
RetKey = 0
function AddThread ( TheFunction, TheOwner )
	DebugPrint ( "NextThreadKe: " .. tostring(NextThreadKey) )
    RetKey = NextThreadKey
    ThreadTable[NextThreadKey] = {Thread = coroutine.create(TheFunction), Owner = TheOwner}
    NextThreadKey = NextThreadKey + 1
    return RetKey
end

-- Stops thread (pass in key returned by AddThread)
function RemoveThread ( ThreadID )
    ThreadTable[ThreadID] = nil
end

--[[ Utility functions ]]

-- Causes program to yield execution
function Yield ()
    coroutine.yield()
end

-- Should wait for TimeSecs but well just do an "update" counter for now
function Sleep ( TimeSecs )
    local StartTime
    local CurrentTime
    StartTime = HostRetTime()
    while true do
        Yield()
        CurrentTime = HostRetTime()
        if HostRetTimeDiff(StartTime,CurrentTime) >= TimeSecs then
            return
        end
    end
end

function LoadLevel ( LevelName )
	_LoadLevel( LevelName );
	repeat
        Yield()
    until ( IsLevelLoaded ( LevelName ) );
end

function DebugPrint ( fmt, ... )
    Emit ( string.format(fmt,unpack(arg)) )
end

function waituntil ( func )
    while ( not func()  ) do
        if ( func ) then
            return
        else
            Yield()
        end
    end
end

-------------------------------------------------------------------------------
--  Actions
-------------------------------------------------------------------------------
function GotoPosition ( Ai, x,y,z )
	HostGotoPosition ( Ai, x,y,z )
	repeat
        DebugPrint ( "Fucking Cock Burgers." )
        Yield()
    until ( HostIsActionDone(Ai) );
end

function GotoObject ( Ai, TargetObject )
	HostGotoObject ( Ai, TargetObject )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function WalkToPosition ( Ai, TargetPosition )
	HostGotoPosition ( Ai, x,y,z, 0.5 )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function WalkToObject ( Ai, TargetObject )
	HostGotoObject ( Ai, TargetObject, 0.5 )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function DriveToPosition ( Ai, TargetPosition )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function DriveToObject ( Ai, TargetObject )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function StopMoving ( Ai )
    HostStopMoving(Ai)
end

function EnterVehicle ( Ai, TargetVehicle )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function LeaveVehicle ( Ai )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

--function JoinGroup ( Ai, Group )
--end

--function LeaveGroup ( Ai )
--end

function PatrolPath ( Ai, TargetPath )
end

function InvestigatePosition ( Ai, TargetPosition )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function PickupObject ( Ai, TargetObject )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function DropObject ( Ai )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function ThrowObject ( Ai, TargetPosition )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function AttackObject ( TargetObject )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

function GuardZone ( Ai, TargetZone )
end

function PerformAction ( Ai, ActionType )
	repeat
        Yield()
    until ( HostIsActionDone(Ai) );
end

-------------------------------------------------------------------------------
--  State Triggers And Utilities
-------------------------------------------------------------------------------
--[[
function GetPos ()
	return HostGetPos(CurrentOwner)
end
function SetPos ( posx, posy, posz )
	HostSetPos(CurrentOwner, posx,posy,posz)
end
]]--
function GetAiAttribute ()		
end

function SetAiAttribute ()		
end

function GetWeaponInfo ()		
end

function SetWeaponInfo ()		
end

function GetInventoryInfo ()		
end

function SetInventoryInfo ()		
end

function IsInZone ()			
end

function IsEnemyDetected ()		
end

function IsEnemyValid ()			
end

function IsAlive ()				
end

function IsFriendly ()			
end

function IsEnemy  ()			
end

function IsNear	 ()			
end

function rand(...)
	-- Replace the maths.random() calls with sync safe versions
	-- Should behave the same way as maths.random()
	AILib.Emit ("RANDOM CALLED")
	if arg.n == 0 then
		return cAIPlayer.FRand(0.0, 1.0)
	elseif arg.n == 1 then
		return cAIPlayer.Rand(1, arg[1])
	else
		return cAIPlayer.Rand(arg[1], arg[2])
	end	
end

-------------------------------------------------------------------------------
-- Startup the scripting system
-------------------------------------------------------------------------------
Init()
Update()
