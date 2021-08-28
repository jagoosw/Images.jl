using Test
using ImageBase
using Suppressor

@testset "Images" begin
include("arrays.jl")
include("algorithms.jl")
@suppress_err include("exposure.jl") # deprecated
include("edge.jl")
include("corner.jl")
include("writemime.jl")

include("legacy.jl")
@suppress_err include("deprecated.jl")

end
