using Elliptic
using PhysicalConstants.CODATA2018: μ_0

export Loop, mfd, conductor_coordinates, conductor_length

"""
    Loop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u"m")

A circular current loop.

# Fields
- `current::Unitful.Current`: The current in the loop.
- `radius::Unitful.Length`: The radius of the loop.
- `height::Unitful.Length`: The height of the loop.
"""
struct Loop{T1<:Unitful.Current,T2<:Unitful.Length,T3<:Unitful.Length} <: Coil
    current::T1
    radius::T2
    height::T3
end

Loop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u"m") =
    Loop(current, radius, height)

"""
    conductor_coordinates(c::Loop)

Returns the coordinates of the conductor in cylindrical coordinates.

# Arguments
- `c::Loop`: The current loop.

# Returns
- `coordinates::Vector{Vector{Unitful.Length}}`: The coordinates of the conductor.
"""
conductor_coordinates(c::Loop) = [[c.radius c.height]]

"""
    conductor_length(c::Loop)

Returns the length of the conductor.

# Arguments
- `c::Loop`: The current loop.

# Returns
- `length::Unitful.Length`: The length of the conductor.
"""
conductor_length(c::Loop) = 2π * c.radius

"""
    mfd(c::Loop, ρ, z)

Computes the magnetic flux density for a current loop in cylindrical coordinates according to Refs. [1] and [2].

- [1]: Simpson, James C. et al. “Simple Analytic Expressions for the Magnetic Field of a Circular Current Loop.” (2001).
- [2]: Jang, Taehun, et al. "Off-axis magnetic fields of a circular loop and a solenoid for the electromagnetic induction of a magnetic pendulum." Journal of Physics Communications 5.6 (2021)

# Arguments
- `c::Loop`: The current loop.
- `ρ::Unitful.Length`: The radial coordinate.
- `z::Unitful.Length`: The axial coordinate.

# Returns
- `B::Vector{Unitful.MagneticFluxDensity}`: The radial and axial components of the magnetic flux density.
"""
function mfd(c::Loop, ρ, z)
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

    return upreferred.([Bρ Bz])
end

"""
    mfd_z(c::Loop, z)

Computes the axial component of the magnetic flux density for a current loop along the axial direction (ρ = 0) according to Ref. [3].

[3]: https://de.wikipedia.org/wiki/Leiterschleife

# Arguments
- `c::Loop`: The current loop.
- `z::Unitful.Length`: The axial coordinate.

# Returns
- `Bz::Unitful.MagneticFluxDensity`: The axial component of the magnetic flux density.
"""
function mfd_z(c::Loop, z)
    I = c.current
    R = c.radius

    Bz = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

    return upreferred.(Bz)
end