
function Main ()
	local count = 0
	local a,x,y,z
    
    Sleep(2)
    --a = Spawn ( "PROP_Barrel_001", GetPos(GetOwner()) )
    a = Spawn ( "AiPlayer.Kingpin", GetPos(GetOwner()) )
    
    ViewDebugInfo ( a, 1 )
    
    while true do
        GotoObject ( a, FindObject("testinfoa") )
        GotoObject ( a, FindObject("testinfob") )
    end
    
    while true do
        GotoPosition ( a, -36,-9,-76 )
        GotoPosition ( a, -36,-9,-45 )
    end
    
    while true do
        x,y,z = GetPos(a)
        y=y+0.1
        SetPos(a,x,y,z)
        Sleep(0)
    end
    
    while true do
        Emit ( "Hello" .. tostring(GetOwner()) )
        Sleep(10);
    end

end

