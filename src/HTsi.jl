module HTsi

using Interpolations
using RemoteFiles
using OptionalData
using StaticArrays
using Statistics
using Dates
using JSON

include("get_path.jl")

include("space_indices.jl")


greet() = print("Hello World! HTsi")

end # module
