--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Program = require("../../src/Program")

describe("Program", function()
	it("round-trips ops through encode and decode with the default fields", function()
		local Ops = { { K = "Insert", L = 1, C = 2, V = 3 }, { K = "Remove", L = 4, T = 9 } }
		local Text = Program.encodeOps(Ops)
		expect(Text).toBe("Insert|1|2|3||||\nRemove|4||||||9")
		expect(Program.decodeOps(Text)).toEqual(Ops)
	end)

	it("uses the field list given, the first field as the op's kind", function()
		local Fields = { "Kind", "Slot", "Value" }
		local Ops = { { Kind = "Push", Slot = 2, Value = 7.5 } }
		local Text = Program.encodeOps(Ops, Fields)
		expect(Text).toBe("Push|2|7.5")
		expect(Program.decodeOps(Text, Fields)).toEqual(Ops)
	end)

	it("decodes an empty program to no ops", function()
		expect(Program.encodeOps({})).toBe("")
		expect(Program.decodeOps("")).toEqual({})
	end)
end)
