using Coils
using Test
using DynamicQuantities
import Unitful

@register_unit Gauss 1e-4u"T"

include("types.jl")
include("conductor_length.jl")
include("magnetic_flux_density.jl")
