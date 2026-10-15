--!strict
--[=[
	@class TestKit

	Domain-agnostic property-testing core: a symbolic-program differential
	fuzzer plus shrinker, mutator, guidance corpus, and an oracle-necessity
	grader. Consumers bind their own Schema/Model/OpGen/Adapter/Oracles on top;
	every module here stays engine-agnostic.
]=]

local Executor = require("@self/Executor")
local Mutator = require("@self/Mutator")
local Guidance = require("@self/Guidance")
local OracleNecessity = require("@self/OracleNecessity")
local Shrink = require("@self/Shrink")
local Program = require("@self/Program")
local SetUtil = require("@self/SetUtil")

local TestKit = {}

TestKit.Executor = Executor
TestKit.Mutator = Mutator
TestKit.Guidance = Guidance
TestKit.OracleNecessity = OracleNecessity
TestKit.Shrink = Shrink
TestKit.Program = Program
TestKit.SetUtil = SetUtil

export type Op = Program.Op

return table.freeze(TestKit)
