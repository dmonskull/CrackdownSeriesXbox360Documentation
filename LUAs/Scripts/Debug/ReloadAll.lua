-- Set the table of loaded files to nil, so any time require is called it will reload the file again
_LOADED = {}

-- Reload all the states
require "State\\World\\World"
