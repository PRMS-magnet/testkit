--!strict
--[[
	Deletes ops one at a time while the list still fails, then lowers each numeric field to
	the smallest value that still fails. Deletion goes first as the cheaper reduction, as in
	Hypothesis.

	A deletion can leave a later op naming something that no longer exists, so the adapter
	must accept such an op; a later pass deletes it if the failure does not need it.
	scopeLegal keeps the field pass from breaking a list whose references are legal, as
	quickcheck-state-machine does.
]]
local Shrink = {}

-- Fields not listed are never lowered; other op shapes pass their own fieldFloor
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

	-- 1. Delete ops, with no scope check, since a later pass deletes an orphan the failure does not need
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

	-- 2. Lower fields, checking scope only when the list is already legal, so one still holding orphans can shrink
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
					-- Binary search assumes failure is monotonic in the field; the accept below confirms the result
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
