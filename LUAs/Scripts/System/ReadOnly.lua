----------------------------------------------------------------------
-- Name: ReadOnly
-- Description: Function to create a read-only table that will assert if you try to write to an element or 
-- access an element that does not exist. This gives run-time behaviour that is similar to the compile-time 
-- behaviour of the C language enumerated type keyword 'enum'
-- Owner: Paul
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------


-- Call this function and pass in a table to create a list, for example:
--	eTypesOfBird = CreateReadOnly
--	{
--		nSparrow = 1,
--		nMagpie = 2,
--		nBlueTit = 3,
--		nGreatTit = 4,
--		nSwan = 5,
--	}
-- This table will then be read-only and spelling mistakes will be captured, for example:
--	local MyBird = eTypesOfBird.nSparrow				-- Ok
--	local MyOtherBird = eTypesOfBird.nSwannn			-- Asserts: Attempt to read non-existent element 'nSwann'
--	eTypesOfBird.nBlueTit = eTypesOfBird.nGreatTit		-- Asserts: Attempt to write to element 'nBlueTit'

function CreateReadOnly (SourceTable)

	-- Create a proxy that will be accessed instead of the real table
	local Proxy = {}

	-- Make our proxy have the same size as the source table. Without this, if you try to get the number
	-- of elements in the table with table.getn () it will return 0
	Proxy.n = table.getn (SourceTable)

	-- Overload the get and set methods of this proxy with a metatable
	local MetaTable = {
	
		-- Overload the get method to assert if we attempt to read an element that does not exist,
		-- otherwise we re-direct the access to the real table
		__index = function (Table, Key)
			assert (SourceTable[Key], "Attempt to read non-existent element '" .. tostring (Key) .. "' of a read-only table")
			return SourceTable[Key]
		end,
		
		-- Overload the set method to always assert
		__newindex = function (Table, Key, Value)
			assert (SourceTable[Key], "Attempt to write to non-existent element '" .. tostring (Key) .. "' of a read-only table")
			assert (false, "Attempt to write to element '" .. tostring (Key) .."' of a read-only table")
		end,
	}
	setmetatable (Proxy, MetaTable)
	
	return Proxy

end
