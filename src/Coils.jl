module Coils

export Coil, CurrentLoop, AxialOffset, Superposition, Solenoid
export mfd
export wires

include("types.jl")
include("wires.jl")
include("mfd.jl")

end # module Coils
