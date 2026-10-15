--!strict
--[[
	The symbolic Program = (Schema, OpList). Ops reference entities by logical id and
	components by schema index, so one artifact serves generation, mutation, shrinking,
	and the regression corpus. encode/decode persist an op list for the corpus; a
	compact line-per-op serialiser is enough - it only needs to replay exactly.
]]
local Program = {}

-- Field 1 (K) is the op kind (string); every other field is a numeric arg
export type Op = { [string]: any }

-- Default field order; other op shapes pass their own field list to encode/decode
local DEFAULT_FIELDS = { "K", "L", "C", "V", "N", "Begin", "Rel", "T" }

function Program.encodeOps(ops: { Op }, fields: { string }?): string
	local order: { string } = fields or DEFAULT_FIELDS
	local lines = {}
	for _, o in ops do
		local cells = {}
		for _, field in order do
			table.insert(cells, o[field] or "")
		end
		table.insert(lines, table.concat(cells, "|"))
	end
	return table.concat(lines, "\n")
end

-- Field 1 (the op kind) decodes as a string; every later field decodes via tonumber
function Program.decodeOps(s: string, fields: { string }?): { Op }
	local order: { string } = fields or DEFAULT_FIELDS
	local ops = {}
	for line in string.gmatch(s, "[^\n]+") do
		local f = string.split(line, "|")
		local op: Op = {}
		op[order[1]] = f[1]
		for j = 2, #order do
			op[order[j]] = tonumber(f[j])
		end
		table.insert(ops, op)
	end
	return ops
end

return Program
