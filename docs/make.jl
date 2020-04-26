using Documenter, HTsi

makedocs(;
    modules=[HTsi],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/htyeim/HTsi.jl/blob/{commit}{path}#L{line}",
    sitename="HTsi.jl",
    authors="htyeim <htyeim@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/htyeim/HTsi.jl",
)
