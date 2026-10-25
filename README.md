# TestKit - Property testing for Luau

*Started: 2026-06-18 | Last major update: 2026-07-01 | Last updated: 2026-10-22*

Runs a list of operations against your code and a simple model of it, checks
that the two agree, and shrinks a failing list to the smallest one that still
fails.

**TestKit is unpolished.** It is published because
[collections](https://github.com/PRMS-magnet/collections) tests with it. It
works, but its API is what that project needed, and a later 0.x release will
change it.

## Status

| area | state |
|---|---|
| Lute | tested |
| dependencies | none |
| tests | [![tests workflow on main](https://github.com/PRMS-magnet/testkit/actions/workflows/test.yml/badge.svg?branch=main&event=push)](https://github.com/PRMS-magnet/testkit/actions/workflows/test.yml) |

Tested with Lute `1.0.1-nightly.20260729`, through
[Luau Run](https://github.com/PRMS-magnet/luau-run).

## Install

```toml
[dev_dependencies]
TestKit = { name = "prms_magnet/testkit", version = "^0.1.0", target = "luau" }
```

## Quick start

A counter with a bug, tested against a plain number:
```luau
local TestKit = require("./luau_packages/TestKit")

-- The code under test: a counter with a bug, it never goes past 3
local function NewCounter()
	local Counter = { Value = 0 }
	function Counter:Add(Amount)
		self.Value = math.min(self.Value + Amount, 3)
	end
	return Counter
end

-- Applies each op to the counter and to its model, a plain number
local function NewAdapter()
	local Adapter = { Counter = NewCounter(), Model = 0 }
	function Adapter:Apply(Op)
		self.Counter:Add(Op.V)
		self.Model += Op.V
	end
	return Adapter
end

-- Each oracle returns a failure message, or nil when the counter matches the model
local Oracles = {
	function(Adapter, OpIndex)
		if Adapter.Counter.Value ~= Adapter.Model then
			return `op {OpIndex}: counter is {Adapter.Counter.Value}, model is {Adapter.Model}`
		end
		return nil
	end,
}

local function Check(Ops)
	return TestKit.Executor.Run(Ops, NewAdapter(), Oracles, 1) -- 1 checks after every op
end

for Seed = 1, 100 do
	math.randomseed(Seed)
	local Ops = {}
	for _ = 1, math.random(1, 10) do
		table.insert(Ops, { K = "add", V = math.random(0, 3) }) -- K is the op's kind; Shrink lowers V by default
	end

	local Failure = Check(Ops)
	if Failure then
		local Smallest = TestKit.Shrink.Reduce(Ops, function(Candidate)
			return Check(Candidate) ~= nil
		end)
		print(`seed {Seed} failed at {Failure}`) -- seed 1 failed at op 4: counter is 3, model is 6
		print(`{#Ops} ops shrunk to {#Smallest}:`) -- 10 ops shrunk to 2:
		print(TestKit.Program.encodeOps(Smallest, { "K", "V" })) -- add|1 and add|3, one per line
		break
	end
end
```

TestKit does not make the ops. Your test generates them, here from
`math.random` with one seed per run, so a failing seed replays exactly.
Oracles run in list order and the first failure ends the run, so put the one
whose message says most first.

## Modules

| Module | What it does |
| --- | --- |
| `Executor` | `Run(ops, adapter, oracles, checkEvery)` applies each op with `adapter:Apply(op)`, runs every oracle each `checkEvery` ops and once after the last, and returns the first failure message or `nil`. |
| `Shrink` | `Reduce(ops, replayFails, scopeLegal?, fieldFloor?)` deletes the ops a failure does not need, then lowers each numeric field to the smallest value that still fails. |
| `Mutator` | `Mutate(ops, rng, mutateField)` changes one op, to explore around an input. |
| `Program` | `encodeOps` and `decodeOps` store an op list one line per op, for a regression corpus. |
| `Guidance` | Keeps a program prefix the first time its state fingerprint is seen. |
| `OracleNecessity` | `Analyze(oracles, runKilled)` drops each oracle in turn, to show which ones a fault needs. |
| `SetUtil` | `Equal`, `Union` and `Disjoint` over presence sets, and `SeqEqual` over sequences. |

## Limits

**An error inside an op is not caught.** `Executor.Run` does not use `pcall`,
so an error in `Apply` or in an oracle ends the run with that error, not a
failure message. Wrap the call in `pcall` in your `replayFails` if a crash
should count as a failure while shrinking.

**`Shrink` lowers only the fields it knows.** By default these are `V`, `C`,
`N`, `Begin`, `L` and `T`. Pass `fieldFloor` to name other fields and the
smallest value each may take.

**`Program` stores numbers only.** The first field is the op's kind, kept as a
string; every other field is read back with `tonumber`.

## Tests

The specs run on Lute with Luau Run:

```sh
luau-run test
```

## Credits

The shrinker follows ideas from
[Hypothesis](https://github.com/HypothesisWorks/hypothesis) by David R.
MacIver (cheaper reductions first) and from
[quickcheck-state-machine](https://hackage.haskell.org/package/quickcheck-state-machine)
(keeping references legal while shrinking).

## License

[MIT](LICENSE)

[AI Policy](https://gist.github.com/PRMS-magnet/2e7588fb66cf472c634589064d8a799d)
