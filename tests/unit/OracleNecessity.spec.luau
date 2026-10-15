--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local OracleNecessity = require("../../src/OracleNecessity")

local function Oracle(Name: string): OracleNecessity.LabelledOracle
	return { name = Name, fn = Name }
end

-- The fault is killed when the subset holds any of the detecting oracles
local function KilledBy(...: string): ({ any }) -> boolean
	local Detecting = { ... }
	return function(Subset: { any }): boolean
		for _, Fn in Subset do
			if table.find(Detecting, Fn) then
				return true
			end
		end
		return false
	end
end

describe("OracleNecessity.Analyze", function()
	local Oracles = { Oracle("Differential"), Oracle("Invariant"), Oracle("Determinism") }

	it("names the oracle the fault survives without as load-bearing", function()
		local Result = OracleNecessity.Analyze(Oracles, KilledBy("Invariant"))
		expect(Result.fullKilled).toBe(true)
		expect(Result.loadBearing).toEqual({ "Invariant" })
		expect(Result.perOracleKilled).toEqual({ Differential = true, Invariant = false, Determinism = true })
	end)

	it("finds none load-bearing when two oracles each catch the fault", function()
		local Result = OracleNecessity.Analyze(Oracles, KilledBy("Differential", "Determinism"))
		expect(Result.fullKilled).toBe(true)
		expect(Result.loadBearing).toEqual({})
	end)

	it("finds none load-bearing when the full suite misses the fault", function()
		local Result = OracleNecessity.Analyze(Oracles, KilledBy())
		expect(Result.fullKilled).toBe(false)
		expect(Result.loadBearing).toEqual({})
		expect(Result.perOracleKilled).toEqual({ Differential = false, Invariant = false, Determinism = false })
	end)
end)
