_LOADED = {}		-- empties the list of loaded files.

require "State\\NPC\\Action\\Vehicles\\Driveto"

Emit ("Starting Sam_Race1...")

for j = 1, NumVehicles do
	if tDrivers[j]:IsInVehicle() then
		tDrivers[j]:SetState( Create(Driveto, 
		{
		--tTarget = tPlayer,			-- vTargetPosition = vPlayerPos, for a direct position
		 vTargetPosition = vTarget,
		 nSpeed = fDriveSpeed,
		bFullPhysics = false,
		bSlowDownAvoidance = true
		}))
	end
end

Emit ("Finished Sam_Race1...")
