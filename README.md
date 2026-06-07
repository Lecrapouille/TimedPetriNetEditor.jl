# TimedPetriNetEditor.jl

[![CI](https://github.com/Lecrapouille/TimedPetriNetEditor.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/Lecrapouille/TimedPetriNetEditor.jl/actions/workflows/CI.yml) [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://lecrapouille.github.io/TimedPetriNetEditor.jl)

Julia bindings for the C++ [TimedPetriNetEditor](https://github.com/Lecrapouille/TimedPetriNetEditor): a timed Petri net / event graph editor and simulator with `(max,+)` algebra.

This package wraps the editor's C ABI and adds ScicosLab-style helpers that are **not** part of [MaxPlus.jl](https://github.com/Lecrapouille/MaxPlus.jl): building a flowshop event graph and displaying its **critical cycle**.

## How it fits with MaxPlus.jl

| Package | Role |
|---------|------|
| **MaxPlus.jl** | Describes the flowshop in pure Julia and writes a `.flowshop` file via [`save_flowshop`](https://lecrapouille.github.io/MaxPlus.jl/flowshop/#MaxPlus.save_flowshop). |
| **TimedPetriNetEditor.jl** | Reads that file ([`show_cr_graph`](https://lecrapouille.github.io/TimedPetriNetEditor.jl/flowshop/#TimedPetriNetEditor.show_cr_graph)), builds the network in C++, and computes/draws the critical cycle. |

The two packages stay independent (no dependency cycle).

## Installation

`MaxPlus.jl` is registered (v0.4). This package is **not** registered yet — install from Git and build the native library:

```sh
git clone --recursive https://github.com/Lecrapouille/TimedPetriNetEditor.git
cd /home/qq/MyGithub/TimedPetriNetEditor.jl
julia --project -e 'import Pkg; Pkg.build("TimedPetriNetEditor")'
```

Details: [Installation guide](https://lecrapouille.github.io/TimedPetriNetEditor.jl/installation/).

## Quick start

```julia
using MaxPlus, TimedPetriNetEditor

PT = MP.([
           2    3.9  0.95 1.1  0.7  1.4
           mp0  mp0  2    1.2  mp0  1.7
           3.7  mp0  2.2  mp0  6.4  mp0
           mp0  mp0  2    mp0  1    1
           1.7  3.1  3    mp0  1.3  mp0
           0.5  3.2  4.3  1.9  1.6  0.4
           1    1    1    1    1    1
           1.5  1.5  1.5  1.2  1.2  1.2
       ])

nm = ones(Int, size(PT, 1))   # 1 machine par classe
np = ones(Int, size(PT, 2))   # 1 palette par classe

show_cr_graph(PT, nm, np; editor=true)
```

See the [flowshop documentation](https://lecrapouille.github.io/TimedPetriNetEditor.jl/flowshop/) for the full pipeline and cross-check with `semihoward`.

## Documentation

Full documentation: **[https://lecrapouille.github.io/TimedPetriNetEditor.jl](https://lecrapouille.github.io/TimedPetriNetEditor.jl)**

| Topic | Page |
|-------|------|
| Installation & prerequisites | [installation](https://lecrapouille.github.io/TimedPetriNetEditor.jl/installation/) |
| Petri net editor API | [petri](https://lecrapouille.github.io/TimedPetriNetEditor.jl/petri/) |
| Flowshop & critical cycle | [flowshop](https://lecrapouille.github.io/TimedPetriNetEditor.jl/flowshop/) |
| Local development | [development](https://lecrapouille.github.io/TimedPetriNetEditor.jl/development/) |
| Tests | [tests](https://lecrapouille.github.io/TimedPetriNetEditor.jl/tests/) |

Build locally: `julia --project=docs -e 'include("docs/make.jl")'`.

## License

GNU GPL v3 (same as TimedPetriNetEditor).
