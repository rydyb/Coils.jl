module Coils

using Unitful

export Coil, CurrentLoop, AxialOffset, ReverseCurrent, Superposition
export Solenoid, Helmholtz, AntiHelmholtz
export mfd
export wires

include("types.jl")
include("wires.jl")
include("mfd.jl")

end # module Coils
