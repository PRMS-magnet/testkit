--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Guidance = require("../../src/Guidance")

describe("Guidance", function()
	it("keeps a prefix only the first time its fingerprint is seen", function()
		local Corpus = Guidance.new()
		expect(Corpus:Observe(11, "first")).toBe(true)
		expect(Corpus:Observe(11, "repeat")).toBe(false)
		expect(Corpus:Observe(12, "second")).toBe(true)
		expect(Corpus:Corpus()).toEqual({ "first", "second" })
	end)

	it("keeps each instance's fingerprints apart", function()
		local One = Guidance.new()
		local Two = Guidance.new()
		One:Observe(5, "one")
		expect(Two:Observe(5, "two")).toBe(true)
		expect(One:Corpus()).toEqual({ "one" })
	end)
end)
