--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Executor = require("../../src/Executor")

local function Recorder()
	return {
		Applied = {} :: { any },
		Apply = function(self, Op: any)
			table.insert(self.Applied, Op)
		end,
	}
end

describe("Executor.Run", function()
	it("applies every op in order and passes when no oracle fails", function()
		local Adapter = Recorder()
		local Pass = function(_: any, _: number): string?
			return nil
		end
		expect(Executor.Run({ "a", "b", "c" }, Adapter, { Pass }, 1)).toBeNil()
		expect(Adapter.Applied).toEqual({ "a", "b", "c" })
	end)

	it("runs the oracles every checkEvery ops and once after the last, past the last index", function()
		local Seen = {}
		local Watch = function(_: any, OpIndex: number): string?
			table.insert(Seen, OpIndex)
			return nil
		end
		Executor.Run({ 1, 2, 3, 4, 5 }, Recorder(), { Watch }, 2)
		expect(Seen).toEqual({ 2, 4, 6 })
	end)

	it("checks once at the end when no checkpoint is reached", function()
		local Seen = {}
		local Watch = function(_: any, OpIndex: number): string?
			table.insert(Seen, OpIndex)
			return nil
		end
		Executor.Run({ 1, 2, 3 }, Recorder(), { Watch }, 10)
		expect(Seen).toEqual({ 4 })
	end)

	it("returns the first failure and applies nothing after it", function()
		local Adapter = Recorder()
		local Calls = 0
		local FailsAtTwo = function(_: any, OpIndex: number): string?
			return if OpIndex == 2 then "broken at 2" else nil
		end
		local Counts = function(_: any, _: number): string?
			Calls += 1
			return nil
		end
		expect(Executor.Run({ 1, 2, 3, 4 }, Adapter, { FailsAtTwo, Counts }, 1)).toBe("broken at 2")
		expect(Adapter.Applied).toEqual({ 1, 2 })
		expect(Calls).toBe(1)
	end)

	it("reports a failure the final check finds", function()
		local AtEnd = function(_: any, OpIndex: number): string?
			return if OpIndex == 3 then "missing at end" else nil
		end
		expect(Executor.Run({ 1, 2 }, Recorder(), { AtEnd }, 5)).toBe("missing at end")
	end)
end)
