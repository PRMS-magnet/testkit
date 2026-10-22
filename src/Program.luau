--!strict
--[[
	Stores an op list one line per op, for a regression corpus that only has to replay
	exactly. The first field is the op's kind; every other field is read back as a number.
]]
local Program = {}

export type Op = { [string]: any }

-- Other op shapes pass their own field list
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
