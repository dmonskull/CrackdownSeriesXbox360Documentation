require ("Fundamental\\Fundamental")

-- Syntactic sugar for defining inheritance (global function)
function Create (Parent, Child)
	assert (Parent)
	assert (Parent ~= Child)

	Child = Parent:Derive (Child)
	
	return Child
end

-- The base object in the hierarchy has no parent
BaseObject = {}

-- Creates a new child of the base object
function BaseObject:Derive (Instance)
	Instance = Instance or {}
	setmetatable(Instance, self)
	self.__index = self

	return Instance
end

-- Checks to see if the current instance is of type 'Object'
function BaseObject:IsA (Object)

	if self == Object then
		return true
	else
		local meta = getmetatable (self)
		
		if meta == nil then
			return false
		else
			if meta.IsA == nil then
				if meta.__index == nil then
					return false
				elseif meta.__index.IsA == nil then
					return false
				else
					return meta.__index:IsA (Object)
				end
			else
				return meta:IsA (Object)
			end
		end
	end

end

