--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local TestKit = require("../../src")

describe("TestKit", function()
	it("exposes each module from its entrypoint, frozen", function()
		expect(TestKit.Executor).toBe(require("../../src/Executor"))
		expect(TestKit.Shrink).toBe(require("../../src/Shrink"))
		expect(TestKit.Mutator).toBe(require("../../src/Mutator"))
		expect(TestKit.Program).toBe(require("../../src/Program"))
		expect(TestKit.Guidance).toBe(require("../../src/Guidance"))
		expect(TestKit.OracleNecessity).toBe(require("../../src/OracleNecessity"))
		expect(TestKit.SetUtil).toBe(require("../../src/SetUtil"))
		expect(table.isfrozen(TestKit)).toBe(true)
	end)
end)
