--!strict
--[[
	Program-level mutator: picks ONE op and replaces ONE of its fields via the supplied
	`mutateField` (the domain strategy lives in the consumer's OpGen). Drives exploration
	around an interesting input. The adapter tolerates ops made illegal by the edit and the
	shrinker re-legalises, so the mutator never has to keep the program legal itself.
]]
local Mutator = {}

-- rng is a Random, or anything with its NextInteger, so the mutator runs on any Luau host
function Mutator.Mutate(ops: { any }, rng: any, mutateField: (any, any) -> any): { any }
	local out = table.clone(ops)
	if #out == 0 then
		return out
	end
	local i = rng:NextInteger(1, #out)
	out[i] = mutateField(out[i], rng)
	return out
end

return Mutator
