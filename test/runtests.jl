using Test, SparseArrays, MaxPlus, TimedPetriNetEditor
using Suppressor

# Locate the C++ repository data directory (for the JSON example nets).
function find_data_dir()
    cands = String[]
    haskey(ENV, "TPNE_CPP_DIR") && push!(cands, joinpath(ENV["TPNE_CPP_DIR"], "data", "examples"))
    push!(cands, normpath(joinpath(@__DIR__, "..", "deps", "TimedPetriNetEditor", "data", "examples")))
    push!(cands, normpath(joinpath(@__DIR__, "..", "..", "TimedPetriNetEditor", "data", "examples")))
    for c in cands
        isdir(c) && return c
    end
    return nothing
end

const LIB_OK = !isempty(TimedPetriNetEditor.libtpne) && isfile(TimedPetriNetEditor.libtpne)
const DATA = find_data_dir()

@testset "TimedPetriNetEditor.jl" begin

    @testset "save_flowshop round-trip (pure Julia, no native lib)" begin
        # MaxPlus.save_flowshop is dependency-free; always testable.
        E = [2.0 3.0 1.0; 1.0 2.0 1.5]
        path = MaxPlus.save_flowshop(E, [1, 1], [1, 1, 1], tempname() * ".flowshop")
        @test isfile(path)
        content = read(path, String)
        @test occursin("npieces: 3", content)
        @test occursin("nmachines: 2", content)
        @test occursin("M1: 2.0 3.0 1.0", content)
        @test occursin("M2: 1.0 2.0 1.5", content)
        # mp0 entries become "nan".
        Eps = [MP(2.0) mp0; MP(1.0) MP(2.0)]
        path2 = MaxPlus.save_flowshop(Eps, [1, 1], [1, 1], tempname() * ".flowshop")
        @test occursin("nan", read(path2, String))
    end

    if !LIB_OK
        @warn "Native library not available — skipping native Petri net tests. " *
              "Build it with `import Pkg; Pkg.build(\"TimedPetriNetEditor\")`." TimedPetriNetEditor.libtpne
        @testset "native calls error cleanly when lib is missing" begin
            @test_throws ErrorException petri_net()
        end
    else
        @testset "basic API" begin
            pn = petri_net()
            @test pn.handle == 0
            @test is_empty(pn) == true
            p0 = add_place!(pn, 100.0, 100.0, 5)
            @test p0 == 0
            add_place!(pn, 200.0, 200.0, 0)
            p2 = add_place!(pn, Place(210.0, 210.0, 10))
            p3 = place(pn, p2)
            @test p3.x == 210.0 && p3.y == 210.0 && p3.tokens == 10
            @test tokens(pn, p0) == 5
            tokens!(pn, p0, 2)
            @test tokens(pn, p0) == 2
            t0 = add_transition!(pn, 150.0, 150.0)
            @test t0 == 0
            add_transition!(pn, 250.0, 250.0)
            @test count_transitions(pn) == 2
            @test count_places(pn) == 3
        end

        if DATA !== nothing
            @testset "event graph / matrices (Howard2.json)" begin
                pn = load_petri(joinpath(DATA, "Howard2.json"))
                @test is_event_graph(pn) == true
                N, T = to_graph(pn)
                @test full(N) == [mp0 mp0 2 mp0; 0 mp0 mp0 mp0; mp0 0 mp0 0; 0 mp0 mp0 mp0]
                @test full(T) == [mp0 mp0 5 mp0; 5 mp0 mp0 mp0; mp0 3 mp0 1; 1 mp0 mp0 mp0]

                cc = find_critical_cycle(pn)
                @test cc.success == true
                @test cc.cycles >= 1
                # Cross-check the cycle time against MaxPlus.howard on the same graph.
                λ_howard = plustimes(MaxPlus.semihoward(T, N).eigenvalues[1])
                @test isapprox(maximum(cc.durations), λ_howard; atol = 1e-9)
            end
        else
            @warn "C++ data/examples directory not found — skipping JSON-based tests."
        end

        @testset "flowshop critical cycle vs semihoward" begin
            E = [2.0 3.0 1.0; 1.0 2.0 1.5]
            m = [1, 1]; p = [1, 1, 1]
            path = MaxPlus.save_flowshop(E, m, p, tempname() * ".flowshop")
            pn = petri_net()
            import_flowshop!(pn, path)
            @test is_event_graph(pn) == true
            cc = find_critical_cycle(pn)
            @test cc.success == true
            T, N = MaxPlus.flowshop_graph(E, m, p)
            λ = plustimes(MaxPlus.semihoward(T, N).eigenvalues[1])
            @test isapprox(maximum(cc.durations), λ; atol = 1e-9)
        end
    end
end
