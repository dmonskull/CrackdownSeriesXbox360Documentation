
function Main ()
	local count = 100
	local a

    while true do
        Emit ( "Even now in the darkness." )
        Sleep(10);
    end

    while true do
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = count / 100;
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
		a = Thing(count);
        DebugPrint ( "Test 2: " .. tostring(count) )
        Sleep ( 10 )
        count = count +1
    end
end

function Thing ( iny )

	local a;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	a = iny *100;
	return a;
end
