--!strict
local JestGlobals = require("@jest/globals")
local describe, it, expect = JestGlobals.describe, JestGlobals.it, JestGlobals.expect

local Shrink = require("../../src/Shrink")

local function Has(Ops: { any }, Kind: string): boolean
	for _, Op in Ops do
		if Op.K == Kind then
			return true
		end
	end
	return false
end

describe("Shrink.Reduce", function()
	it("deletes every op the failure does not need", function()
		local Ops = { { K = "a", V = 5 }, { K = "b", V = 3 }, { K = "c", V = 9 } }
		local Fails = function(Candidate: { any }): boolean
			return Has(Candidate, "b")
		end
		expect(Shrink.Reduce(Ops, Fails, nil, {})).toEqual({ { K = "b", V = 3 } })
	end)

	it("keeps every op the failure needs, in order", function()
		local Ops = { { K = "a" }, { K = "b" }, { K = "c" }, { K = "d" } }
		local Fails = function(Candidate: { any }): boolean
			return Has(Candidate, "a") and Has(Candidate, "c")
		end
		expect(Shrink.Reduce(Ops, Fails, nil, {})).toEqual({ { K = "a" }, { K = "c" } })
	end)

	it("reduces a numeric field to the smallest value that still fails", function()
		local Fails = function(Candidate: { any }): boolean
			return #Candidate == 1 and Candidate[1].V >= 37
		end
		expect(Shrink.Reduce({ { K = "x", V = 1000 } }, Fails, nil, { V = 0 })).toEqual({ { K = "x", V = 37 } })
	end)

	it("takes each field to its default floor when no floors are given", function()
		local Always = function(_: { any }): boolean
			return true
		end
		local Ops = { { K = "x", C = 50, V = 20, Rel = 7 } }
		-- Only one op survives deletion, since any program fails; Rel has no default floor
		expect(Shrink.Reduce(Ops, Always)).toEqual({})
		local NeedsOne = function(Candidate: { any }): boolean
			return #Candidate == 1
		end
		expect(Shrink.Reduce(Ops, NeedsOne)).toEqual({ { K = "x", C = 1, V = 0, Rel = 7 } })
	end)

	it("refuses a value edit the scope gate rejects once the program is legal", function()
		local NeedsOne = function(Candidate: { any }): boolean
			return #Candidate == 1
		end
		local Legal = function(Candidate: { any }): boolean
			return Candidate[1] == nil or Candidate[1].V >= 5
		end
		expect(Shrink.Reduce({ { K = "x", V = 40 } }, NeedsOne, Legal, { V = 0 })).toEqual({ { K = "x", V = 5 } })
	end)

	it("leaves the input untouched", function()
		local Ops = { { K = "a", V = 8 }, { K = "b", V = 8 } }
		local Fails = function(Candidate: { any }): boolean
			return Has(Candidate, "b")
		end
		Shrink.Reduce(Ops, Fails, nil, { V = 0 })
		expect(Ops).toEqual({ { K = "a", V = 8 }, { K = "b", V = 8 } })
	end)
end)
