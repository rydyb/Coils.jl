module Coils

using Unitful

export Coil, CurrentLoop, Pancake, Solenoid, Helical, Helmholtz, AntiHelmholtz
export mfd, mfd_z
export wires

include("wire.jl")
include("magnetism.jl")
include("fluid.jl")

end # module Coils
