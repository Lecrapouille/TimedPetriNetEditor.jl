using Pkg

const DOC_DIR = dirname(@__FILE__)

Pkg.activate(DOC_DIR)
Pkg.instantiate()

ENV["GKSwstype"] = get(ENV, "GKSwstype", "100")

using Documenter
using Documenter.Remotes
using MaxPlus

push!(LOAD_PATH, joinpath(DOC_DIR, "..", "src"))
using TimedPetriNetEditor

# Generate index.md from top-level README.md, adjusting links for Documenter
infile = joinpath(DOC_DIR, "..", "README.md")
outfile = joinpath(DOC_DIR, "src", "index.md")
open(outfile, "w") do out
    for line in readlines(infile)
        line = replace(line, "](docs/src/" => "](")
        line = replace(line, "](installation.md)" => "](installation.md)")
        write(out, line * "\n")
    end
end

makedocs(
    modules = [TimedPetriNetEditor],
    warnonly = true,
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        edit_link = "master",
        repolink = "https://github.com/Lecrapouille/TimedPetriNetEditor.jl",
    ),
    sitename = "TimedPetriNetEditor.jl",
    repo = Remotes.GitHub("Lecrapouille", "TimedPetriNetEditor.jl"),
    authors = "Quentin Quadrat",
    pages = [
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Petri net editor" => "petri.md",
        "Flowshop & critical cycle" => "flowshop.md",
        "Development" => "development.md",
        "Tests" => "tests.md",
    ],
)

deploydocs(
    repo = "github.com/Lecrapouille/TimedPetriNetEditor.jl.git",
    branch = "gh-pages",
    devbranch = "master",
    devurl = "master",
)

rm(joinpath(DOC_DIR, "src", "index.md"); force=true)
