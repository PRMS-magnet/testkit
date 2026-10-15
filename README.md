# TestKit - Property testing for Luau

*Last updated: 2026-10-15*

Runs a list of operations against your code and a simple model of it, checks
that the two agree, and shrinks a failing list to the smallest one that still
fails.

## Status

| area | state |
|---|---|
| Lute | tested |
| Roblox | not tested in Studio yet |
| dependencies | none |
| tests | [![tests workflow on main](https://github.com/PRMS-magnet/testkit/actions/workflows/test.yml/badge.svg?branch=main&event=push)](https://github.com/PRMS-magnet/testkit/actions/workflows/test.yml) |

Tested with Lute `1.0.1-nightly.20260729`, through
[Luau Run](https://github.com/PRMS-magnet/luau-run).

TestKit is a development dependency. Your tests use it; your package does not
ship it.

## Install

```toml
[dev_dependencies]
TestKit = { name = "prms_magnet/testkit", version = "^0.1.0", target = "luau" }
```

## Quick start

```luau
local TestKit = require("./luau_packages/TestKit")

-- A counter with a bug: it never goes past 3. The model is a plain number.
local function NewAdapter()
	local Adapter = { Real = 0, Model = 0 }
	function Adapter:Apply(Op)
		self.Real = math.min(self.Real + Op.V, 3)
		self.Model += Op.V
	end
	return Adapter
end

local Oracles = {
	function(Adapter, OpIndex)
		if Adapter.Real ~= Adapter.Model then
			return `op {OpIndex}: counter is {Adapter.Real}, model is {Adapter.Model}`
		end
		return nil
	end,
}

local function Fails(Ops)
	return TestKit.Executor.Run(Ops, NewAdapter(), Oracles, 1) ~= nil
end

local Ops = { { K = "add", V = 1 }, { K = "add", V = 2 }, { K = "add", V = 5 }, { K = "add", V = 1 } }
print(TestKit.Executor.Run(Ops, NewAdapter(), Oracles, 1)) -- op 3: counter is 3, model is 8
print(TestKit.Program.encodeOps(TestKit.Shrink.Reduce(Ops, Fails), { "K", "V" })) -- add|4
```

The adapter applies each op to your code and to the model. An oracle is
`function(adapter, opIndex): string?`: it returns a failure message, or `nil`
when the state is right. Oracles run in list order and the first failure ends
the run, so put the one whose failure says most first.

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
