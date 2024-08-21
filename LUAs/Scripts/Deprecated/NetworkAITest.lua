require "Guard"

NetworkAITest = Create (Behaviour,
{
	-- Define member variables
	NPCs = { nil, nil, nil }
})

function NetworkAITest:OnEnter ()
	-- Call parent
	Behaviour.OnEnter (self)

	-- Spawn the leader and make him patrol
	self.NPCs[1] = SpawnNPC("AI Street Soldier Machine Gun", 35.0, -0.5, 30.0)
	--self.NPCs[1]:SetBehaviour(Guard)

	self.Waypoints = {
		MakeVec3(-10, -1, 20), 
		MakeVec3(-10, -1, 90), 
		MakeVec3(60, -1, 90), 
		MakeVec3(60, -1, 20), 
	}

	self.GuardBehaviour = Create (Guard, {Waypoints=self.Waypoints})

	self.NPCs[1]:SetBehaviour(self.GuardBehaviour)

end


function NetworkAITest:OnEvent (event)
	-- Call parent
	Behaviour.OnEvent (self, event)


end
