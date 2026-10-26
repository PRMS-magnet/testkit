# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `Executor.Run` runs a list of ops against your code and a model of it, and
  returns the first failure an oracle reports.
- `Shrink.Reduce` cuts a failing list down to the smallest one that still
  fails.
- `Mutator`, `Program`, `Guidance`, `OracleNecessity` and `SetUtil`, the
  helpers collections' fuzz tests use.
