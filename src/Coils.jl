module Coils

using Unitful

@derived_dimension SpecificHeatCapacity dimension(u"J/(kg*K)")
@derived_dimension ThermalConductivity dimension(u"W/(m*K)")
@derived_dimension VolumeFlow dimension(u"m^3/s")

include("wire.jl")
include("magnetism.jl")
include("fluid.jl")

end # module Coils
