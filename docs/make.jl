using EcoTrialStructure
using Documenter

DocMeta.setdocmeta!(EcoTrialStructure, :DocTestSetup, :(using EcoTrialStructure); recursive=true)

makedocs(;
    modules=[EcoTrialStructure],
    authors="Tim Holy <tim.holy@gmail.com> and contributors",
    repo="https://github.com/HolyLab/EcoTrialStructure.jl/blob/{commit}{path}#{line}",
    sitename="EcoTrialStructure.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://HolyLab.github.io/EcoTrialStructure.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/HolyLab/EcoTrialStructure.jl",
    devbranch="main",
)
