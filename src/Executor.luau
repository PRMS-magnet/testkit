--!strict
--[[
	Generic driver: applies a Program's ops through an adapter, running each oracle at
	checkpoints (+ once at the end). Returns the first oracle failure string, or nil.
	Oracles are `function(adapter, opIndex) -> string?` - the Executor knows nothing
	about the engine, only the adapter + oracle contract.
]]
local Executor = {}

function Executor.Run(ops: { any }, adapter: any, oracles: { (any, number) -> string? }, checkEvery: number): string?
	for i, op in ops do
		adapter:Apply(op)
		if i % checkEvery == 0 then
			for _, oracle in oracles do
				local fail = oracle(adapter, i)
				if fail then
					return fail
				end
			end
		end
	end
	for _, oracle in oracles do
		local fail = oracle(adapter, #ops + 1)
		if fail then
			return fail
		end
	end
	return nil
end

return Executor
