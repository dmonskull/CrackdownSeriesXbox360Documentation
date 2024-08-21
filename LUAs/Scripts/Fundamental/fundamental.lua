require "Fundamental\\Math"
require "Fundamental\\Enums"
require "Fundamental\\Constants"

function namespace (tNamespace)
	_G[tNamespace] = _G[tNamespace] or {}

	setmetatable(_G[tNamespace], {__index = _G})
	setfenv(2, _G[tNamespace])
end

function endnamespace ()
	namespace ("_G")
end
