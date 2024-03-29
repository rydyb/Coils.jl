using Elliptic
using PhysicalConstants.CODATA2018: μ_0

export CurrentLoop

"""
    CurrentLoop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u"m")

A circular current CurrentLoop.

# Keywords
- `current::Unitful.Current`: The current running through the loop.
- `radius::Unitful.Length`: The radius of the current loop.
- `height::Unitful.Length`: The height of the current loop, zero by default.
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

"""
    mfd(c::CurrentLoop, ρ, z)

Computes the magnetic flux density according to analytical solution to the Biot-Savart law, see [1] and [2].

- [1]: Simpson, James C. et al. “Simple Analytic Expressions for the Magnetic Field of a Circular Current Loop.” (2001).
- [2]: Jang, Taehun, et al. "Off-axis magnetic fields of a circular loop and a solenoid for the electromagnetic induction of a magnetic pendulum."

# Arguments
- `c::CurrentLoop`: The CurrentLoop.
- `ρ::Unitful.Length`: The radial coordinate.
- `z::Unitful.Length`: The axial coordinate.

# Returns
- `Vector{Unitful.MagneticFluxDensity}`: The radial and axial magnetic flux density components.
"""
function mfd(c::CurrentLoop, ρ, z)
    I = c.current
    R = c.radius
    z = z - c.height

    # α becomes zero for z -> 0 when ρ -> R
    if iszero(z) && R ≈ ρ
        return [0.0, 0.0] .* u"Gauss"
    end

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - α² / β^2

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = μ_0 * I / 2π

    # Bρ diverges for ρ -> 0
    if iszero(ρ)
        Bρ = 0.0u"Gauss"
    else
        Bρ = (C / (α² * β)) * ((R^2 + ρ^2 + z^2) * E - α² * K) * (z / ρ)
    end

    Bz = (C / (α² * β)) * ((R^2 - ρ^2 - z^2) * E + α² * K)

    return uconvert.(u"Gauss", [Bρ, Bz])
end

"""
    mfdz(c::CurrentLoop[, z])

Computes the magnetic flux density along the z-axis according to [1].

- [1]: https://de.wikipedia.org/wiki/Leiterschleife

# Arguments
- `c::CurrentLoop`: The CurrentLoop.
- `z::Unitful.Length`: The axial coordinate by default equal to the height of current loop `c`.

# Returns
- `Vector{Unitful.MagneticFluxDensity}`: The radial and axial magnetic flux density components.
"""
function mfdz(c::CurrentLoop, z = c.height)
    I = c.current
    R = c.radius
    z = z - c.height

    Bρ = 0.0u"Gauss"
    Bz = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

    if iszero(Bz)
        Bz = Bρ
    end

    return uconvert.(u"Gauss", [Bρ, Bz])
end