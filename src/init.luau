--!strict
--[[
	Property testing against a model. The caller supplies the ops, the adapter that
	applies them and the oracles that check it; nothing here knows what is being tested.
]]

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
