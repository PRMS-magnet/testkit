--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Mutator = require("../../src/Mutator")

-- Any value with NextInteger stands in for Random, so the pick is known
local function FixedPick(Index: number): any
	return {
		NextInteger = function(_: any, Low: number, High: number): number
			assert(Low == 1 and Index <= High, "the pick is outside the program")
			return Index
		end,
	}
end

describe("Mutator.Mutate", function()
	it("replaces exactly the picked op with mutateField's result", function()
		local Ops = { 1, 2, 3 }
		local Times10 = function(Op: any, _: any): any
			return Op * 10
		end
		expect(Mutator.Mutate(Ops, FixedPick(2), Times10)).toEqual({ 1, 20, 3 })
		expect(Ops).toEqual({ 1, 2, 3 })
	end)

	it("returns an empty copy of an empty program without mutating", function()
		local Called = false
		local Mark = function(Op: any, _: any): any
			Called = true
			return Op
		end
		local Ops = {}
		local Result = Mutator.Mutate(Ops, FixedPick(1), Mark)
		expect(Result).toEqual({})
		expect(Result ~= Ops).toBe(true)
		expect(Called).toBe(false)
	end)
end)
