# Development

## Local checkout layout

Clone the three repositories side by side:

```
MyGithub/
├── MaxPlus.jl/                # optional: only if you modify MaxPlus
├── TimedPetriNetEditor/       # C++ sources
└── TimedPetriNetEditor.jl/    # this package
```

```julia
import Pkg
Pkg.develop(path="/home/me/MyGithub/MaxPlus.jl")          # optional
Pkg.develop(path="/home/me/MyGithub/TimedPetriNetEditor.jl")
Pkg.build("TimedPetriNetEditor")
```

Because the C++ checkout is a sibling, no `TPNE_CPP_DIR` is needed.

## Build internals

`deps/build.jl` resolves the C++ directory (env var → submodule → sibling), drives the GNU Make build, and writes the shared library path into `deps/deps.jl` (auto-generated — do not edit). If the library is missing, `__init__` warns and every native call re-checks, so a broken build never crashes precompilation.

## Building the documentation

From the package root:

```julia
import Pkg
Pkg.activate("docs")
Pkg.instantiate()
include("docs/make.jl")
```

## GitHub Pages (`github.io`)

The site is published at **[https://lecrapouille.github.io/TimedPetriNetEditor.jl](https://lecrapouille.github.io/TimedPetriNetEditor.jl)**.

Documenter builds the HTML locally and, on CI, pushes it to the `gh-pages` branch. To set this up on a new repository:

1. **Push** this repository to GitHub (`Lecrapouille/TimedPetriNetEditor.jl`).
2. **Enable GitHub Pages** in the repository settings:
   - *Settings* → *Pages*
   - *Build and deployment* → *Source*: **Deploy from a branch**
   - *Branch*: **`gh-pages`** / **`/ (root)`**
3. **Push to `master` or `main`**. The CI *Documentation* job runs `docs/make.jl`, which calls `deploydocs` and creates or updates `gh-pages`.
4. After a minute or two, the site is live at `https://<user>.github.io/TimedPetriNetEditor.jl/`.

No `DOCUMENTER_KEY` is required when deploying to `gh-pages` on the same repository: the workflow passes `GITHUB_TOKEN` (with `contents: write`). The key is only needed for [TagBot](https://github.com/JuliaRegistries/TagBot.jl) release tags.

To deploy manually from your machine (optional):

```julia
ENV["GITHUB_REPOSITORY"] = "Lecrapouille/TimedPetriNetEditor.jl"
ENV["GITHUB_TOKEN"] = "<personal access token with repo scope>"
ENV["GITHUB_EVENT_NAME"] = "push"
include("docs/make.jl")
```

Each push to the default branch refreshes the *dev* documentation (`devurl = "master"` in `docs/make.jl`).

## Registering the package

`MaxPlus.jl` is already in General; this package is not. To register it:

1. **Public Git repository** with a valid `Project.toml` (`name`, `uuid`, `version`, `[compat]` for every dependency including `julia`).
2. **Installable from a clean machine** without a local sibling checkout:
   - Vendor C++ sources as submodule `deps/TimedPetriNetEditor`, and/or
   - Document `TPNE_CPP_DIR` for users who already have the C++ repo.
   - Long term: ship the native library via [BinaryBuilder](https://github.com/JuliaPackaging/BinaryBuilder.jl) as a `*_jll` artifact (recommended for registered packages with native code).
3. **Trigger registration** via the [Registrator](https://github.com/JuliaRegistries/Registrator.jl) bot (`@JuliaRegistrator register` on the release commit, or the [web UI](https://juliahub.com/ui/Registrator)). Tag the release (e.g. `v0.1.0`) and keep CI green. See [General registry guidelines](https://github.com/JuliaRegistries/General#registering-a-new-package).
4. **Bump `version`** in `Project.toml` for each subsequent release.

Registering does **not** remove the C++ build step unless you also ship a `*_jll` artifact. Until then, the [system prerequisites](installation.md) still apply.

## C++ Julia binding source

The C ABI consumed by this package is implemented in the upstream repository under `src/julia/` (`Julia.hpp`, `Julia.cpp`). The historical cheatsheet lives in `doc/julia.md`.
