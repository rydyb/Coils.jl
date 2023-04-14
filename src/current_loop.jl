using Elliptic
using PhysicalConstants.CODATA2018: μ_0

export CurrentLoop
export mfd_z

"""
    CurrentLoop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u"m")

A circular current CurrentLoop.

# Fields
- `current::Unitful.Current`: The current in the CurrentLoop.
- `radius::Unitful.Length`: The radius of the CurrentLoop.
- `height::Unitful.Length`: The height of the CurrentLoop.
"""
struct CurrentLoop{T1<:Unitful.Current,T2<:Unitful.Length,T3<:Unitful.Length} <: Coil
    current::T1
    radius::T2
    height::T3
end

CurrentLoop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u"m") =
    CurrentLoop(current, radius, height)

conductor_coordinates(c::CurrentLoop) = [(c.radius, c.height)]
conductor_length(c::CurrentLoop) = 2π * c.radius

function mfd(c::CurrentLoop, ρ, z)
    I = c.current
    R = c.radius
    z = z - c.height

    # α becomes zero for z -> 0 when ρ -> R
    if iszero(z) && R ≈ ρ
        return [0u"T" 0u"T"]
    end

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - α² / β^2

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = μ_0 * I / 2π

    # Bρ diverges for ρ -> 0
    if iszero(ρ)
        Bρ = 0u"T"
    else
        Bρ = (C / (α² * β)) * ((R^2 + ρ^2 + z^2) * E - α² * K) * (z / ρ)
    end

    Bz = (C / (α² * β)) * ((R^2 - ρ^2 - z^2) * E + α² * K)

    return upreferred(Bρ), upreferred(Bz)
end

function mfd_z(c::CurrentLoop, z)
    I = c.current
    R = c.radius
    z = z - c.height

    Bz = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

    return upreferred(Bz)
end