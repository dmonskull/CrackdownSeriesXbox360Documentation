-------------------------------------------------------------------------------
GuardKingpinVillaCavernEntrance = {}

function GuardKingpinVillaCavernEntrance.Triggers ()
	if EnemyDetected() then GosubState ( AttackEnemy ) end
end

function GuardKingpinVillaCavernEntrance.Actions ()
    WalkTo ( "Kingpin Villa Cavern Entrance Guard Spot" )
end

-------------------------------------------------------------------------------
PatrolKingpinVillaLowerLevel = {}

function PatrolKingpinVillaLowerLevel.Triggers ()

	if EnemyDetected() then GosubState ( AttackEnemy) end
    
end

function PatrolKingpinVillaLowerLevel.Actions ()

	WalkTo ( "Kingpin Villa Lower Level" )
	WalkRoundPath ( "Kingpin Villa Lower Level Guard Path" )
    
end

-------------------------------------------------------------------------------
GuardKingpinVillaFrontGate = {}

function GuardKingpinVillaFrontGate.Triggers ()

	if EnemyDetected() then GosubState ( AttackEnemy) end
    
end
    
function GuardKingpinVillaFrontGate.Actions ()

    WalkTo ( "kingpin Villa Front Gate" )

end

-------------------------------------------------------------------------------
Investigate = {}

function Investigate.Triggers ()

	if EnemyDetected() then GotoState ( AttackAnemy ) end
    
end

function Investigate.Actions ()

    WalkTo ( InvestigationSpot )
    LookAround()
	ReturnState()
    
end

-------------------------------------------------------------------------------
AttackEnemy = {}

function AttackEnemy.Triggers ()

	if not EnemyIsValid() then ReturnState() end
    
end

function AttackEnemy.Actions ()

    Attack ( Enemy() )
    
end
