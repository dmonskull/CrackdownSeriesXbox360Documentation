----------------------------------------------------------------------
-- Name: Crime State
--	Description: The gang members harass the pedestrian
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Mission\\MissionState"
require "State\\Crime\\LMAssault\\Harass"
require "State\\Crime\\LMAssault\\Taunt"
--require "State\\Crime\\LMAssault\\Victim"
require "State\\NPC\\Action\\Animation\\FullBodyAnimate"
require "State\\Crime\\LMAssault\\TauntAndAttack"
require "State\\Crime\\LMAssault\\Reset"


namespace ("LMAssault")

Crime = Create (MissionState,
{
	sStateName = "Crime",
})


TauntEnemyAnimation2 = Create (FullBodyAnimate,
{
    sStateName = "TauntEnemyAnimation2",
})


function Crime:OnEnter ()
	-- Call parent
	MissionState.OnEnter (self)

	-- Debugging text
	self.tHost:SetCrimeDebugString ("In Crime state")

	-- Check parameters
	assert (self.tVictim)
	assert (self.atGangMember)

	-- Determine which gang member should be the harasser
	self.tHarasser = self:RetHarasser ()

	-- Set up gang members to harass victim
	for i, tGangMember in pairs (self.atGangMember) do

		if tGangMember == self.tHarasser then
        
            tGangMember:SetState (Create (TauntAndAttack,
            {
                tVictim = self.tVictim,
            }))
           
		else
			tGangMember:SetState (Create (Taunt,
			{
				tTarget = self.tVictim,
				tHarasser = self.tHarasser,
			}))
		end

	end

	-- Set up victim
--	self.tVictim:SetState (Create (Victim,
--	{
--		atGangMember = self.atGangMember,
--		tTarget = self.tHarasser,
--		vCenter = self.tHost:RetPosition (),
--	}))

	-- Subscribe events
	self.nVictimDeletedID = self:Subscribe (eEventType.AIE_OBJECT_DELETED, self.tVictim)
	self.nHarasserEventID = self:Subscribe (eEventType.AIE_CUSTOM, self.tHarasser)
    
end

function Crime:OnExit ()

	if self.tVictim then

		if self.bDeleteMissionObjects then

			-- Delete the victim
			AILib.DeleteGameObject (self.tVictim)

		else
			-- Reset the victim to be a pedestrian again
			self.tVictim:SetState (Pedestrian)
			self.tVictim:SetGameImportance (eGameImportance.nDefault)

		end

	end

	-- Call parent
	MissionState.OnExit (self)
end

function Crime:RetNumGangMembers ()
	return table.getn (self.atGangMember)
end

-- Return array index of the gang member who is furthest from the victim
function Crime:RetHarasser ()

	local nMaxDist = 0
	local tBestGangMember = nil

	for i, tGangMember in pairs (self.atGangMember) do

		local nDistance = AILib.CharacterDist (tGangMember, self.tVictim)
		if nDistance > nMaxDist then
			tBestGangMember = tGangMember
			nMaxDist = nDistance
		end

	end

	return tBestGangMember
end

function Crime:OnEvent (tEvent)
	
	if tEvent:HasID (self.nVictimDeletedID) then

		-- Victim has been deleted, reset immediately regardless of anything else
		self:SetDeleteMissionObjects (false)
		self:Finish ()
		return true
        
    elseif tEvent:HasID (self.nHarasserEventID) and tEvent:HasCustomEventID ("HarassFinished") then

		self:SetDeleteMissionObjects (false)
		self:Finish ()
		return true

    elseif tEvent:HasID (self.nHarasserEventID) and tEvent:HasCustomEventID ("BeatingEnded") then
     
        -- reset the crime
        self:Finish ()
        return true

	end

end

