using SquidGame
using Documenter

DocMeta.setdocmeta!(SquidGame, :DocTestSetup, :(using SquidGame); recursive=true)

makedocs(;
    modules=[SquidGame],
    authors="Andrew Rosemberg",
    repo="https://github.com/andrewrosemberg/SquidGame.jl/blob/{commit}{path}#{line}",
    sitename="SquidGame.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://andrewrosemberg.github.io/SquidGame.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    checkdocs=:exports,
    strict=true,
)

deploydocs(;
    repo="github.com/andrewrosemberg/SquidGame.jl",
    devbranch="main",
)
