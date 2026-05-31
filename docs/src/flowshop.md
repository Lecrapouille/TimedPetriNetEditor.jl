# Flowshop & critical cycle

ScicosLab functions that draw the flowshop timed event graph and highlight its **critical cycle** are not part of [MaxPlus.jl](https://github.com/Lecrapouille/MaxPlus.jl). This package provides them by wrapping the C++ editor.

## Pipeline with MaxPlus.jl

| Step | Package | Function |
|------|---------|----------|
| 1. Describe the flowshop | **MaxPlus.jl** | `save_flowshop(E, m, p, path)` → `.flowshop` file |
| 2. Build & analyse the graph | **TimedPetriNetEditor.jl** | `show_cr_graph(path)` → critical cycle report |

There is **no dependency cycle**: `MaxPlus.jl` only writes the text file; it never calls the native library.

## Processing-time matrix `E`

Rows are machine classes, columns are part classes. Use a `(max,+)` matrix: durations are `MP(...)` values, missing tasks are `mp0` (the `(max,+)` zero, i.e. `-∞`).

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

m = [1, 1, 1, 1, 1, 1]   # machine counts per row of E
p = [2, 2, 2, 1, 1, 1]   # pallet counts per column of E
```

The same matrix is used in the [MaxPlus.jl flowshop tutorial](https://github.com/Lecrapouille/MaxPlus.jl/blob/master/tutorial/flowshop-en.ipynb).

## Show critical cycle

```julia
G = save_flowshop(E, m, p, "demo.flowshop")
res = show_cr_graph(G)              # pass editor=true to open the GUI
@show res.cycles res.durations[1]     # cycle time ≈ 13.3

# Or pass E, m, p directly (writes a temporary .flowshop file):
res = show_cr_graph(E, m, p; editor=false)
```

Return value: a named tuple `(; success, cycles, durations, eigenvector)` from [`find_critical_cycle`](@ref).

Cross-check with MaxPlus (same cycle time as `semihoward`):

```julia
T, N = flowshop_graph(E, m, p)
λ = plustimes(semihoward(T, N).eigenvalues[1])   # == res.durations[1]
```

## Lower-level API

Build the net step by step instead of using the ScicosLab-style shortcut:

```julia
pn = petri_net()
import_flowshop!(pn, "demo.flowshop")
@show is_event_graph(pn)

cc = find_critical_cycle(pn)
petri_editor!(pn)   # optional GUI
```

## `.flowshop` file format

Written by `MaxPlus.save_flowshop` and read by `import_flowshop!` / `show_cr_graph`:

- Header: `npieces`, `nmachines`, `nm`, `np`, `pieces`
- One line per machine: `M<j>: t1 t2 …` (missing tasks written as `nan`)

## API reference

```@docs
TimedPetriNetEditor.import_flowshop!
TimedPetriNetEditor.find_critical_cycle
TimedPetriNetEditor.show_cr_graph
```

See also the MaxPlus.jl docs: [`save_flowshop`](https://lecrapouille.github.io/MaxPlus.jl/flowshop/#MaxPlus.save_flowshop), [`flowshop_graph`](https://lecrapouille.github.io/MaxPlus.jl/flowshop/#MaxPlus.flowshop_graph).
