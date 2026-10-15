# TestKit

Property testing for Luau. A test is a program: a list of ops. TestKit runs
it through your adapter, which drives your implementation and a simple
reference model side by side, checks your oracles as it goes, and shrinks a
failing program to a small one.

TestKit is a development dependency. Your tests use it; your package does not
ship it.

## Install

```toml
[dev_dependencies]
TestKit = { name = "prms_magnet/testkit", version = "^0.1.0", target = "luau" }
```

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

An oracle is `function(adapter, opIndex): string?`. It returns a failure
message, or `nil` when the state is right. Oracles run in list order and the
first failure ends the run, so put the one whose failure says most first.

## Tests

The specs run on Lute with [Luau Run](https://github.com/PRMS-magnet/luau-run):

```sh
luau-run test
```

## License

MIT
