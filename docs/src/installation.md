# Installation

`MaxPlus.jl` is registered in the Julia General registry (v0.4) and is pulled in automatically as a dependency. `TimedPetriNetEditor.jl` is **not** registered yet — install it from its Git URL and build the native library.

## System prerequisites

Installing this package compiles native C++ code. You need:

| Requirement | Notes |
|-------------|-------|
| `g++` (C++14+), `make`, `git` | Build toolchain |
| ZeroMQ | `dnf install zeromq-devel` · `apt install libzmq3-dev` · `pacman -S zeromq` · `brew install zeromq` |
| OpenGL (`glfw`, `glew`) | Only for the optional GUI editor |

## C++ sources

Clone the upstream repository (with submodules):

```sh
git clone --recursive https://github.com/Lecrapouille/TimedPetriNetEditor.git
```

`Pkg.build` locates the checkout in this order:

1. Environment variable `TPNE_CPP_DIR` (absolute path to your checkout)
2. Git submodule `deps/TimedPetriNetEditor`
3. Sibling directory `../TimedPetriNetEditor` next to this package

If the C++ repo already sits beside `TimedPetriNetEditor.jl`, no environment variable is needed. Otherwise:

```sh
# Replace with YOUR actual checkout path — not a placeholder like /path/to/...
TPNE_CPP_DIR=/home/me/TimedPetriNetEditor \
  julia -e 'import Pkg; Pkg.add(url="https://github.com/Lecrapouille/TimedPetriNetEditor.jl"); Pkg.build("TimedPetriNetEditor")'
```

!!! tip
    If you see `TPNE_CPP_DIR is set but not a directory`, the path is wrong. Use a real absolute path on your machine.

During the build, `deps/build.jl` runs the C++ Makefile (`download-external-libs`, `compile-external-libs`, `make`), finds `libTimedPetriJulia.so`, and writes its path to `deps/deps.jl`.

A failed C++ build only affects this package: `MaxPlus.jl` keeps working, the module still loads, and native calls raise a clear error until the library is built.

## From Julia

```julia
import Pkg
Pkg.add(url="https://github.com/Lecrapouille/TimedPetriNetEditor.jl")
Pkg.build("TimedPetriNetEditor")
```

See [Development](development.md) for a local checkout layout with `Pkg.develop`.
