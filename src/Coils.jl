module Coils

using Unitful

"""
    Coil

An abstract type for a magnetic coil.
"""
abstract type Coil end

include("loop.jl")
include("helical.jl")
include("pair.jl")
include("loops.jl")

end # module Coils
