export VerticalTranslation
export mfd
export length

struct VerticalTranslation{T1<:Unitful.Length} <: Conductor
    height::T1
    conductor::Conductor
end

function conductor_length(c::VerticalTranslation)
    return length(c.conductor)
end

function magnetic_flux_density(c::VerticalTranslation, ρ, z)
    # TODO: make this work for arbitrary arguments (how do we identify the z coordinate?)
    return mfd(c.conductor, ρ, z - c.height)
end

