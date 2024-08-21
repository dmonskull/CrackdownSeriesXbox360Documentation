----------------------------------------------------------------------
-- Name: Crime State
-- Description: The gang members attack each other
-- Owner: pkg
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\Crime\\AmbientCrimeState"
require "State\\Crime\\SGFreakEscape\\SGFreakEscapeTeam"

namespace ("SGFreakEscape")

Crime = Create (State,
{
	sStateName = "Crime",
})

function Crime:OnEnter ()
	-- Call parent
	AmbientCrimeState.OnEnter (self)

	-- Let the teams take over for the combat behaviour
	self.tParent.tTeam1:SetState (Create (SGFreakEscapeTeam,	{}))
	self.tParent.tTeam2:SetState (Create (SGFreakEscapeTeam,	{}))

end

function Crime:OnExit ()
	self.tParent.tTeam1:ClearState ()
	self.tParent.tTeam2:ClearState ()
	AmbientCrimeState.OnExit (self)
end
