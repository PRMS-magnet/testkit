--!strict
--[[
	Applies each op with adapter:Apply and runs the oracles every checkEvery ops, then once
	after the last op with #ops + 1 as the index. Errors are not caught, so the caller
	decides whether a crash counts as a failure.
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
