export Conductor
export conductor_length
export magnetic_field_density

abstract type Conductor end

NotImplementedError = error("not implemented")

conductor_length(::Conductor) = NotImplementedError

magnetic_flux_density(::Conductor, args...) = NotImplementedError