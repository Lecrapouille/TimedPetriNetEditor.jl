# Petri net editor

Julia bindings for the C++ [TimedPetriNetEditor](https://github.com/Lecrapouille/TimedPetriNetEditor) graphical editor and simulator. Each Petri net lives in a C++ container; Julia holds an opaque handle (`PetriNet`) that stays valid even when other nets are created or destroyed.

## Quick example

```julia
using TimedPetriNetEditor

# Load an example net (JSON format)
pn = load_petri("data/examples/Howard2.json")

# Check structure and analyse as an event graph
@show is_event_graph(pn)
N, T = to_graph(pn)

# Compute the critical cycle (semi-Howard)
cc = find_critical_cycle(pn)
@show cc.cycles maximum(cc.durations)

# Open the GUI editor (press Escape to quit and apply changes)
petri_editor!(pn)
```

For a non-destructive edit, duplicate first:

```julia
pn2 = petri_editor(pn)   # pn is unchanged; edits apply to pn2
```

## Creating and loading nets

```julia
pn = petri_net()                          # empty net
pn = petri_net("path/to/net.json")        # load from JSON
pn2 = petri_net(pn)                       # duplicate

@show is_empty(pn)
clear!(pn)                                # remove all nodes and arcs

save_petri(pn, "/tmp/net.json")
load_petri!(pn, "/tmp/net.json")         # load into existing handle
pn3 = load_petri("/tmp/net.json")         # load into a new handle
```

!!! note "Saving"
    An empty net cannot be saved.

## Places and transitions

Places carry `(x, y)` layout coordinates and a token count. Transitions carry `(x, y)` coordinates only.

```julia
p0 = add_place!(pn, 100.0, 100.0, 5)      # x, y, tokens → place id
p1 = add_place!(pn, Place(200.0, 200.0, 0))

t0 = add_transition!(pn, 150.0, 150.0)
t1 = add_transition!(pn, Transition(250.0, 250.0))

@show place(pn, p0)
@show transition(pn, t0)
@show places(pn) transitions(pn)
@show count_places(pn) count_transitions(pn)

tokens(pn, p0)          # tokens in one place
tokens!(pn, p0, 2)      # set tokens in one place
tokens!(pn, [0, 1, 2])  # set all place markings at once
@show tokens(pn)        # marking vector

remove_place!(pn, p1)
remove_transition!(pn, t0)
```

Node identifiers returned by `add_place!` / `add_transition!` are stable until the node is removed.

## Event graph analysis

A timed event graph is a Petri net where every place has exactly one input arc and one output arc.

```julia
@show is_event_graph(pn)

pn_can = canonic(pn)   # canonical form (≤ 1 token per place)

N, T = to_graph(pn)    # sparse (max,+) adjacency: tokens N, durations T
S = to_syslin(pn)      # implicit (max,+) linear system MPSysLin

show_dater_equation(pn, true, false)    # dater form (max notation)
show_counter_equation(pn, true, true)   # counter form (min-plus notation)
```

`N`, `T`, and the matrices inside `S` use `MaxPlus.MP` scalars and integrate directly with [MaxPlus.jl](https://github.com/Lecrapouille/MaxPlus.jl) (`semihoward`, `mpeigen`, …).

## Types

```@docs
TimedPetriNetEditor.PetriNet
TimedPetriNetEditor.Place
TimedPetriNetEditor.Transition
TimedPetriNetEditor.Arc
```

## API reference

### Net lifecycle

```@docs
TimedPetriNetEditor.petri_net()
TimedPetriNetEditor.petri_net(::String)
TimedPetriNetEditor.petri_net(::TimedPetriNetEditor.PetriNet)
TimedPetriNetEditor.is_empty
TimedPetriNetEditor.clear!
TimedPetriNetEditor.load_petri
TimedPetriNetEditor.load_petri!
TimedPetriNetEditor.save_petri
```

### GUI editor

```@docs
TimedPetriNetEditor.petri_editor!
TimedPetriNetEditor.petri_editor
```

### Places

```@docs
TimedPetriNetEditor.add_place!
TimedPetriNetEditor.remove_place!
TimedPetriNetEditor.places
TimedPetriNetEditor.place
TimedPetriNetEditor.count_places
TimedPetriNetEditor.tokens
TimedPetriNetEditor.tokens!
```

### Transitions

```@docs
TimedPetriNetEditor.add_transition!
TimedPetriNetEditor.remove_transition!
TimedPetriNetEditor.transitions
TimedPetriNetEditor.transition
TimedPetriNetEditor.count_transitions
```

### Event graphs

```@docs
TimedPetriNetEditor.is_event_graph
TimedPetriNetEditor.canonic
TimedPetriNetEditor.to_graph
TimedPetriNetEditor.to_syslin
TimedPetriNetEditor.show_dater_equation
TimedPetriNetEditor.show_counter_equation
```

## Example JSON nets

When the C++ repository is available (submodule, sibling checkout, or `TPNE_CPP_DIR`), example nets live under `data/examples/` — for instance `Howard2.json`, `JPQ.json`, `TrafficLights.json`. They are used by the package tests.

## Limitations

Arc creation and removal are not yet exposed in the Julia API (nets are built from JSON, flowshop import, or the GUI editor).
