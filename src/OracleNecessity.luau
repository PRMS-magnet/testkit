--!strict
--[[
	Oracle-necessity matrix. For a fault the full suite kills, drop each oracle in turn and
	see if the fault survives: a survival proves that oracle is the load-bearing detector, a
	continued kill proves it is redundant for this fault. The union of load-bearing oracles
	across all fault mutants is the proof the suite has no dead-weight oracle.
]]
local OracleNecessity = {}

export type LabelledOracle = { name: string, fn: any }

export type Result = {
	fullKilled: boolean,
	loadBearing: { string },
	perOracleKilled: { [string]: boolean },
}

local function dropOne(oracles: { LabelledOracle }, skip: number): { any }
	local subset = {}
	for i, o in oracles do
		if i ~= skip then
			table.insert(subset, o.fn)
		end
	end
	return subset
end

function OracleNecessity.Analyze(oracles: { LabelledOracle }, runKilled: (subset: { any }) -> boolean): Result
	local all = {}
	for _, o in oracles do
		table.insert(all, o.fn)
	end
	local fullKilled = runKilled(all)

	local loadBearing = {}
	local perOracleKilled = {}
	for i, o in oracles do
		local killed = runKilled(dropOne(oracles, i))
		perOracleKilled[o.name] = killed
		if fullKilled and not killed then
			table.insert(loadBearing, o.name)
		end
	end

	return { fullKilled = fullKilled, loadBearing = loadBearing, perOracleKilled = perOracleKilled }
end

export type OracleNecessity = typeof(OracleNecessity)

return OracleNecessity
