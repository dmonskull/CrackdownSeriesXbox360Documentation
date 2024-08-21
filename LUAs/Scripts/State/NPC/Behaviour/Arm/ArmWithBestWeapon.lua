----------------------------------------------------------------------
-- Name: ArmWithBestWeapon State
-- Description: Equip with the best weapon in the inventory for attacking
-- the current target
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "State\\NPC\\TargetState"
require "State\\NPC\\Action\\Equipment\\EquipItem"
require "State\\NPC\\Action\\Equipment\\StoreItem"

ArmWithBestWeapon = Create (TargetState, 
{
	sStateName = "ArmWithBestWeapon",
	nTargetInfoFlags = eTargetInfoFlags.nVisibilityChecks + eTargetInfoFlags.nPrimaryFireChecks,
	bCanFirearmAttack = true,
	bCanUseCurrentFirearm = true,
})

function ArmWithBestWeapon:OnEnter ()
	-- Call parent
	TargetState.OnEnter (self)

	-- Search inventory for a weapon we can use to attack the target without
	-- hurting friendlies - we don't care about other checks such as 'in range' and
	-- 'not blocked' as we can move to a better position

	local tBestEquipment = nil
	local nBestPriority = 0

	if self.bCanFirearmAttack then

		-- Loop through weapons in inventory
		for i=1, self.tHost:RetInventorySize () do
	
			tCurrentEquipment = self.tHost:RetEquipmentFromPosition (i-1)
	
			-- We are only interested in primary weapons
			if tCurrentEquipment:RetEquipmentType () == eEquipmentType.nPrimary then
	
				-- Prefer weapons with higher priority
				if tCurrentEquipment:RetWeaponPriority () > nBestPriority then
	
					-- If this is our current primary equipment already then we don't need to
					-- do the target area clear test again as that info is cached
					if self.tHost:IsCurrentPrimaryEquipmentEquiped () and
						self.tHost:RetCurrentPrimaryEquipment () == tCurrentEquipment then
			
						if self.bCanUseCurrentFirearm and
							self.tTargetInfo:IsPrimaryFireAreaClear () then
							tBestEquipment = tCurrentEquipment
							nBestPriority = tCurrentEquipment:RetWeaponPriority ()
						end
			
					else
			
						if tCurrentEquipment:IsTargetAreaClear (
							self.tHost:RetCharacter (),
							self.tTargetInfo:RetCharacterTarget (),
							self.tHost:RetCentre (),
							self.tTargetInfo:RetLastTargetFocusPointPosition (),
							false) then
				
							tBestEquipment = tCurrentEquipment
							nBestPriority = tCurrentEquipment:RetWeaponPriority ()
						end
			
					end
	
				end
	
			end
	
		end

	end

	-- Equip with weapon, if one is found, otherwise use hand to hand
	if tBestEquipment then
		self:PushState (Create (EquipItem, 
		{
			tEquipment = tBestEquipment,
		}))
	else
		self:PushState (Create (StoreItem, {}))
	end

end

function ArmWithBestWeapon:OnActiveStateFinished ()

	if self:IsInState (EquipItem) then

		self:Finish ()
		return true

	elseif self:IsInState (StoreItem) then

		self:Finish ()
		return true

	end

	-- Call parent
	return TargetState.OnActiveStateFinished (self)
end
