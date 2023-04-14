using Documenter, Coils

makedocs(
    modules = [Coils],
    sitename = "Coils.jl",
    pages = Any[
        "Coils.jl"=>"index.md",
        "API references"=>Any[
            "api/coil.md",
            "api/current_loop.md",
            "api/helical.md",
            "api/helmholtz.md",
            "api/current_loops.md",
        ],
    ],
)

deploydocs(repo = "github.com/rydyb/Coils.jl.git")