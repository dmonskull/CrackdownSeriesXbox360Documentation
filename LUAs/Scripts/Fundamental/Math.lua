----------------------------------------------------------------------
-- Name: Math Library
-- Description: All math functions written in Lua (the complex ones should
-- be written in c++ of course)
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

require "Fundamental\\Vec3"

function AddAngles (a, b)
	local c = a + b
	if c >= 360 then
		c = c - 360
	elseif c < 0 then
		c = c + 360
	end
	return c
end

function Max (a, b)
	if a > b then
		return a
	else
		return b
	end
end

function Min (a, b)
	if a < b then
		return a
	else
		return b
	end
end
