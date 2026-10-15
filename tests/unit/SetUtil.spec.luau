--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local SetUtil = require("../../src/SetUtil")

describe("SetUtil", function()
	it("compares presence sets whatever order they were built in", function()
		expect(SetUtil.Equal({ [1] = true, [7] = true }, { [7] = true, [1] = true })).toBe(true)
		expect(SetUtil.Equal({ [1] = true }, { [1] = true, [2] = true })).toBe(false)
		expect(SetUtil.Equal({ [1] = true, [2] = true }, { [1] = true })).toBe(false)
		expect(SetUtil.Equal({}, {})).toBe(true)
	end)

	it("unites two sets without changing either", function()
		local A, B = { [1] = true }, { [2] = true }
		expect(SetUtil.Union(A, B)).toEqual({ [1] = true, [2] = true })
		expect(A).toEqual({ [1] = true })
		expect(B).toEqual({ [2] = true })
	end)

	it("finds sets disjoint only when they share nothing", function()
		expect(SetUtil.Disjoint({ [1] = true }, { [2] = true })).toBe(true)
		expect(SetUtil.Disjoint({ [1] = true, [3] = true }, { [3] = true })).toBe(false)
	end)

	it("compares sequences in order and by length", function()
		expect(SetUtil.SeqEqual({ 1, 2, 3 }, { 1, 2, 3 })).toBe(true)
		expect(SetUtil.SeqEqual({ 1, 2, 3 }, { 3, 2, 1 })).toBe(false)
		expect(SetUtil.SeqEqual({ 1, 2 }, { 1, 2, 3 })).toBe(false)
	end)
end)
