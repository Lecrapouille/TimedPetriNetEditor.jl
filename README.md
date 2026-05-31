# TimedPetriNetEditor.jl

Julia bindings for the C++ [TimedPetriNetEditor](https://github.com/Lecrapouille/TimedPetriNetEditor): a timed Petri net / event graph editor and simulator with `(max,+)` algebra.

This package wraps the editor's C ABI and adds ScicosLab-style helpers that are **not** part of [MaxPlus.jl](https://github.com/Lecrapouille/MaxPlus.jl): building a flowshop event graph and displaying its **critical cycle**.

## How it fits with MaxPlus.jl

| Package | Role |
|---------|------|
| **MaxPlus.jl** | Describes the flowshop in pure Julia and writes a `.flowshop` file via [`save_flowshop`](https://lecrapouille.github.io/MaxPlus.jl/flowshop/#MaxPlus.save_flowshop). |
| **TimedPetriNetEditor.jl** | Reads that file ([`show_cr_graph`](docs/src/flowshop.md)), builds the network in C++, and computes/draws the critical cycle. |

The two packages stay independent (no dependency cycle).

## Quick start

```julia
using MaxPlus, TimedPetriNetEditor

E = MP.([
    2    3.9  0.95 1.1  0.7  1.4
    mp0  mp0  2    1.2  mp0  1.7
    3.7  mp0  2.2  mp0  6.4  mp0
    mp0  mp0  2    mp0  1    1
    1.7  3.1  3    mp0  1.3  mp0
    0.5  3.2  4.3  1.9  1.6  0.4
])

m = [1, 1, 1, 1, 1, 1]
p = [2, 2, 2, 1, 1, 1]

G = save_flowshop(E, m, p, "demo.flowshop")
res = show_cr_graph(G; editor=false)
@show res.cycles res.durations[1]   # cycle time ≈ 13.3
```

See the [flowshop documentation](docs/src/flowshop.md) for the full pipeline and cross-check with `semihoward`.

## Installation

`MaxPlus.jl` is registered (v0.4). This package is **not** registered yet — install from Git and build the native library:

```sh
git clone --recursive https://github.com/Lecrapouille/TimedPetriNetEditor.git
TPNE_CPP_DIR=/path/to/TimedPetriNetEditor \
  julia -e 'import Pkg; Pkg.add(url="https://github.com/Lecrapouille/TimedPetriNetEditor.jl"); Pkg.build("TimedPetriNetEditor")'
```

Details: [Installation guide](docs/src/installation.md).

## Documentation

| Topic | Page |
|-------|------|
| Installation & prerequisites | [installation.md](docs/src/installation.md) |
| Petri net editor API | [petri.md](docs/src/petri.md) |
| Flowshop & critical cycle | [flowshop.md](docs/src/flowshop.md) |
| Local development | [development.md](docs/src/development.md) |
| Tests | [tests.md](docs/src/tests.md) |

Build the Documenter site locally: `julia --project=docs -e 'include("docs/make.jl")'`.

## License

GNU GPL v3 (same as TimedPetriNetEditor).
