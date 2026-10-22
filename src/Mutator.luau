--!strict
--[[
	Replaces one random op with mutateField's version of it, to explore near an input that
	found something. The result can be illegal, such as an op on something already deleted,
	so the adapter must accept such ops.
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
