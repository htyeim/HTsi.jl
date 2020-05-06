using Documenter, HTsi

makedocs(;
    modules = [HTsi],
    format = Documenter.HTML(),
    pages = [
        "Index" => "index.md",
        "Home"  => "index.md",
        "Geomagnetic ndex"      => [
            "Ap Kp Index" => "ApKp.md",
            ],
        "Flux" => "flux.md",
        hide("Dst.md"),

    ],
    repo = "https://github.com/htyeim/HTsi.jl/blob/{commit}{path}#L{line}",
    sitename = "some space indices",
    authors = "htyeim <htyeim@gmail.com>",
    assets = String[],
)

deploydocs(;
    repo = "github.com/htyeim/HTsi.jl",
)
