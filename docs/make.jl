using Documenter
using DFUtil
using Dates


makedocs(
    modules = [DFUtil],
    sitename="DFUtil.jl", 
    authors = "Matt Lawless",
    format = Documenter.HTML(),
)

deploydocs(
    repo = "github.com/lawless-m/DFUtil.jl.git", 
    devbranch = "main",
    push_preview = true,
)
