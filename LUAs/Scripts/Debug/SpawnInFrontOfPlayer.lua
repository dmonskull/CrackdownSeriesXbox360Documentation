-- Return a position a short distance in front of the player

function RetPosInFrontOfPlayer (nDist)

	nDist = nDist or 10

	local tAiManager = cAiManager.RetAiManager ()
	local tPlayer = tAiManager:RetPlayer (0)
	
	local vPos = tPlayer:RetPosition ()
	local nYaw = tPlayer:RetHeading ()
	
	local vDir = AILib.YawToVec (nYaw)	-- Get the direction the player is facing as a vector
	
	vDir = VecMultiply (vDir, nDist)
	vPos = VecAdd (vPos, vDir)
	vPos = VecAdd (vPos, MakeVec3 (0, 0.1, 0))	-- Spawn it a bit above the ground

	return vPos

end

-- Spawn an object (such as a prop) in front of the player

function SpawnInFrontOfPlayer (sProtoName, nDist)
	
	local vPos = RetPosInFrontOfPlayer (nDist)
	return AILib.Spawn (sProtoName, eGameImportance.nDefault, 0, vPos)

end

-- Spawn an NPC in front of the player

function SpawnNPCInFrontOfPlayer (sProtoName, sSpawnScript, nDist)

	local vPos = RetPosInFrontOfPlayer (nDist)
	if sSpawnScript then
		return cAIPlayer.SpawnNPCWithScript (sProtoName, sSpawnScript, vPos)
	else
		return cAIPlayer.SpawnNPC (sProtoName, vPos)
	end

end
