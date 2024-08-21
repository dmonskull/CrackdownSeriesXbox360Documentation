-- Spew all the variables in the global environment (_G) to the console

for n in pairs (_G) do 
	AILib.Emit (tostring (n)) 
end
