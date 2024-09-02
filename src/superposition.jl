export Superposition
export mfd
export length

struct Superposition{T<:Conductor} <: Conductor
    conductors::Vector{T}
end

function conductor_length(c::Superposition)
    return sum(length(c) for c in c.conductors)
end

function magnetic_flux_density(c::Superposition, ρ, z)
    Bρ, Bz = 0u"T", 0u"T"

    for c in c.conductors
        Bρ += mfd(c, ρ, z)[1]
        Bz += mfd(c, ρ, z)[2]
    end

    return uconvert.(u"Gauss", [Bρ, Bz])
end