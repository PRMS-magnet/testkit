--!strict
-- Helpers for oracles; a set maps each member to true
local SetUtil = {}

function SetUtil.Disjoint(a: { [number]: boolean }, b: { [number]: boolean }): boolean
	for e in a do
		if b[e] then
			return false
		end
	end
	return true
end

function SetUtil.Equal(a: { [number]: boolean }, b: { [number]: boolean }): boolean
	for e in a do
		if not b[e] then
			return false
		end
	end
	for e in b do
		if not a[e] then
			return false
		end
	end
	return true
end

function SetUtil.Union(a: { [number]: boolean }, b: { [number]: boolean }): { [number]: boolean }
	local u = {}
	for e in a do
		u[e] = true
	end
	for e in b do
		u[e] = true
	end
	return u
end

function SetUtil.SeqEqual(a: { number }, b: { number }): boolean
	if #a ~= #b then
		return false
	end
	for i = 1, #a do
		if a[i] ~= b[i] then
			return false
		end
	end
	return true
end

return SetUtil
