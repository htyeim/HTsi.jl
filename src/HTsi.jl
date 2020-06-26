module HTsi

using Interpolations
using RemoteFiles
using OptionalData
using StaticArrays
using Statistics
using Dates
using Printf


const path_si_root = joinpath(homedir(), "RD", "SPI")

include("space_indices.jl")

greet() = print("Hello World! HTsi")

end # module
