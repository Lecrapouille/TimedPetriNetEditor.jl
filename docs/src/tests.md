# Tests

From the Julia REPL:

```julia
import Pkg; Pkg.test("TimedPetriNetEditor")
```

## What is tested

- **`save_flowshop` round-trip** (pure Julia via MaxPlus.jl, no native library required)
- **Basic Petri net API** (create places/transitions, tokens) when the native library is built
- **Event graph matrices** on `Howard2.json` when C++ example data is available
- **Flowshop critical cycle** vs `MaxPlus.semihoward` on a small example

## Environment for JSON-based tests

Tests look for example nets in:

1. `$TPNE_CPP_DIR/data/examples`
2. `deps/TimedPetriNetEditor/data/examples` (git submodule)
3. `../TimedPetriNetEditor/data/examples` (sibling checkout)

If none is found, JSON-based tests are skipped with a warning.

## Missing native library

When `libTimedPetriJulia.so` is not built, native calls are expected to raise a clear error; the test suite verifies this behaviour instead of skipping silently.
