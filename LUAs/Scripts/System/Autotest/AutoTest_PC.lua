--[[***************************************
 * AutoTest_PC
 * ----------
 *
 * Test script - intended to be run from UserStartup.ini
 * Tries to load various typical levels
 *
 * OWNER: AB 24/03/2004
 *
 * (c)2004 Real Time Worlds Ltd.
 ***************************************]]



function CountdownAndQuit ()
	local CountDown;
	CountDown = 5;

    -- This makes the script loop forever
	while ( CountDown > 0 ) do
		if (CountDown == 5) then
			ConsoleCommand ( "warning Game will Quit in 5 seconds" );		
		elseif (CountDown == 4) then
			ConsoleCommand ( "warning Game will Quit in 4 seconds" );		
		elseif (CountDown == 3) then
			ConsoleCommand ( "warning Game will Quit in 3 seconds" );		
		elseif (CountDown == 2) then
			ConsoleCommand ( "warning Game will Quit in 2 seconds" );		
		elseif (CountDown == 1) then
			ConsoleCommand ( "warning Game will Quit in 1 seconds" );
        end

		-- Stops executing this script for 1 second
		Sleep(1.0);
        
		CountDown = CountDown - 1;
	end

	ConsoleCommand ( "quit" );
end


function Main ()
	--------------------------------
	-- Frontend Level

	--ConsoleCommand( "warning AutoTest - Navigating Frontend via XCR recording..." );

	--Sleep(6.0);

	--ConsoleCommand( "xcr select ddplay" );
	--ConsoleCommand( "xcr startplayback d:\\autotest_frontend.xcr" );

	--------------------------------
    -- M7 Demo Level
 --   repeat Sleep (5) until (IsLevelLoaded ("devfrontend"))

	Sleep(20.0);
    
	--------------------------------
	-- All the other levels
	
	ConsoleCommand( "warning AutoTest - Loading devfrontend" );
	Sleep( 0.5 );
	HostLoadLevel( "devfrontend" );
	Sleep( 5.0 );

	-- PAT: As of 20/10/04, this level has problems with RW_PATHNODES (obsolete resources?)
	ConsoleCommand( "warning AutoTest - SKIPPING StarGame, because it's been broken." );
	Sleep( 1 );
--	ConsoleCommand( "warning AutoTest - Loading StarGame" );
--	Sleep( 0.5 );
--	HostLoadLevel( "StarGame" );
--	Sleep( 5.0 );

	ConsoleCommand( "warning AutoTest - Loading AnimationTest" );
	Sleep( 0.5 );
	HostLoadLevel( "AnimationTest" );
	Sleep( 5.0 );

	-- PAT: As of 20/10/04, this level has problems with RW_PATHNODES (obsolete resources?)
	ConsoleCommand( "warning AutoTest - SKIPPING dansbit, because it's been broken." );
	Sleep( 1 );
--	ConsoleCommand( "warning AutoTest - Loading dansbit" );
--	Sleep( 0.5 );
--	HostLoadLevel( "dansbit" );
--	Sleep( 5.0 );

	-- PAT: As of 20/10/04, this level produces an assertions about needing an AI Manager.
	ConsoleCommand( "warning AutoTest - SKIPPING PropTest, because it's been broken." );
	Sleep( 1 );
--	ConsoleCommand( "warning AutoTest - Loading PropTest" );
--	Sleep( 0.5 );
--	HostLoadLevel( "PropTest" );
--	Sleep( 5.0 );

	-- PAT: This is an out-of-date level name
--	ConsoleCommand( "warning AutoTest - Loading VehicleTest" );
--	Sleep( 0.5 );
--	HostLoadLevel( "VehicleTest" );
--	Sleep( 5.0 );

	-- PAT: As of 20/10/04, this level produces an assertions about needing an AI Manager.
	ConsoleCommand( "warning AutoTest - SKIPPING Jonathans_vehicle_test_level, because it's been broken." );
	Sleep( 1 );
--	ConsoleCommand( "warning AutoTest - Loading Jonathans_vehicle_test_level" );
--	Sleep( 0.5 );
--	HostLoadLevel( "Jonathans_vehicle_test_level" );
--	Sleep( 5.0 );

	-- PAT: As of 20/10/04, this level produces ASSERT::NoCat: m_pClump.ptr ()
	ConsoleCommand( "warning AutoTest - SKIPPING Network_City level, because it's been broken." );
	Sleep( 1 );
--	ConsoleCommand( "warning AutoTest - Loading Network_City" );
--	Sleep( 0.5 );
--	HostLoadLevel( "Network_City" );
--	Sleep( 5.0 );

	ConsoleCommand( "warning AutoTest - Loading Bills_Test_Level" );
	Sleep( 0.5 );
	HostLoadLevel( "Bills_Test_Level" );
	Sleep( 5.0 );

	CountdownAndQuit();
end
