----------------------------------------------------------------------
-- Name: TauntAndAttack State
--	Description: Taunt followed by a good beating.
-- Owner: Russ
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

--require "State\\Mission\\MissionState"
require "State\\NPC\\Behaviour\\Combat\\Combat"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\NPC\\Action\\Chase\\GetInProximity"

namespace ("LMAssault")

TauntAndAttack = Create (MissionState,
{
	sStateName = "TauntAndAttack",
})

-- taunt animation
TauntAnimation1 = Create (FullBodyAnimate,
{
	sStateName = "TauntAnimation1",
--    nAnimationID = eFullBodyAnimationID.nTaunt1,
    nAnimationID = eFullBodyAnimationID.nUpYours,
})

function TauntAndAttack:OnEnter ()

	-- Call parent
	MissionState.OnEnter (self)
    
        self:PushState (Create (GetInProximity, 
        {
        	tTarget = self.tVictim,
            nRadius = 4,
        }))

end


function TauntAndAttack:OnActiveStateFinished ()

	local tState = self:RetActiveState ()

	if tState:IsA (GetInProximity) then

    -- Play taunt animation
	self:ChangeState (Create (TauntAnimation1, {}))
    
    self.tHost:ShoutEnemyWarningAudio (eVocals.nInsult, "Your going down, yer big southern HEAMER", tEntity) 
    
    return true
    
    end               

	if tState:IsA (TauntAnimation1) then

		-- change to attack
 		self:ChangeState (Create (Combat, 
        {
        	tTarget = self.tVictim,
			bCanTakeCover = false,
			bCanGrenadeAttack = false,
			bCanFirearmAttack = false,
			bCanPropAttack = false,
			bCanCircle = false,
        }))
		return true
        
    end

    if tState:IsA (Combat) then
    
        self.tHost:NotifyCustomEvent ("BeatingEnded")
    
	return true
 
    end

    
	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
