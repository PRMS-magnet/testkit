--!strict
--[[
	Delta-debugging shrinker. First delete-and-retry to a minimal failing op sequence
	(orphaned ops are tolerated by the executor, so a deletion that orphans a later op is
	safe - the orphan is pruned in a later pass). Then an argument-level pass binary-reduces
	each surviving op's numeric fields toward their floor, keeping the smallest value that
	still fails. The optional `scopeLegal` predicate (the consumer's Precondition.ScopeLegal)
	gates argument shrinks once the program is reference-legal, so a value/ref edit never
	introduces a dangling reference (qsm remapVars). Delete passes run before argument passes
	(cheaper size-reducers first, DRMacIver). Pass a `fieldFloor` map for op shapes whose
	numeric fields differ from the default.
]]
local Shrink = {}

-- Default per-field floor for the argument pass; fields absent here are not value-shrunk. Other op shapes pass their own via Reduce's fieldFloor arg
local DEFAULT_FIELD_FLOOR = { V = 0, C = 1, N = 1, Begin = 0, L = 1, T = 1 }

local function withField(ops: { any }, index: number, field: string, value: number): { any }
	local out = table.clone(ops)
	local op = table.clone(out[index])
	op[field] = value
	out[index] = op
	return out
end

function Shrink.Reduce(
	ops: { any },
	replayFails: ({ any }) -> boolean,
	scopeLegal: (({ any }) -> boolean)?,
	fieldFloor: { [string]: number }?
): { any }
	local cur = ops

	-- 1. Delete-and-retry (no scope gate: tolerate-then-prune handles orphans)
	local changed = true
	while changed do
		changed = false
		for r = #cur, 1, -1 do
			local cand = {}
			for p, o in cur do
				if p ~= r then
					table.insert(cand, o)
				end
			end
			if replayFails(cand) then
				cur = cand
				changed = true
			end
		end
	end

	-- 2. Argument pass: only enforce scope once the base is already reference-legal, so a
	-- program still carrying tolerated orphans is not blocked from value-shrinking
	local enforceScope = scopeLegal ~= nil and scopeLegal(cur)
	local function accept(cand: { any }): boolean
		return replayFails(cand) and (not enforceScope or (scopeLegal :: any)(cand))
	end

	local floors: { [string]: number } = fieldFloor or DEFAULT_FIELD_FLOOR
	changed = true
	while changed do
		changed = false
		for i = 1, #cur do
			for field, floor in floors do
				local orig = cur[i][field]
				if type(orig) == "number" and orig > floor then
					-- binary-reduce toward the floor: smallest still-failing value
					local lo, hi = floor, orig
					while lo < hi do
						local mid = (lo + hi) // 2
						if accept(withField(cur, i, field, mid)) then
							hi = mid
						else
							lo = mid + 1
						end
					end
					if lo < orig and accept(withField(cur, i, field, lo)) then
						cur = withField(cur, i, field, lo)
						changed = true
					end
				end
			end
		end
	end

	return cur
end

return Shrink
