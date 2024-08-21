----------------------------------------------------------------------
-- Name: Vec3 Library
--	Description: All functions relating to Lua vectors
-- Owner: Nathan
-- (c) 2005 Real Time Worlds
----------------------------------------------------------------------

function MakeVec3 (xVal, yVal, zVal)
	return {x = xVal, y = yVal, z = zVal}
end

function Vec3ToXYZ (Vec)
	return Vec.x, Vec.y, Vec.z
end

function Vec3ToString (Vec)
	return Vec.x .. ", " .. Vec.y .. ", " .. Vec.z
end

function VecAdd (a, b)
	return MakeVec3 (a.x + b.x, a.y + b.y, a.z + b.z)
end

function VecSubtract (a, b)
	return MakeVec3 (a.x - b.x, a.y - b.y, a.z - b.z)
end

function VecMultiply (a, c)
	return MakeVec3 (a.x * c, a.y * c, a.z * c)
end

function VecDivide (a, c)
	return MakeVec3 (a.x / c, a.y / c, a.z / c)
end

function VecDotProduct (a, b)
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
end

function VecSquaredDistance (a, b)
	local v = VecSubtract (b, a)
	return VecDotProduct (v, v)
end

function VecDistance (a, b)
	return AILib.Dist (a, b)
end

vOrigin = MakeVec3 (0, 0, 0)
vXAxis = MakeVec3 (1, 0, 0)
vYAxis = MakeVec3 (0, 1, 0)
vZAxis = MakeVec3 (0, 0, 1)
