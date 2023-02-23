using Elliptic
using Unitful
using PhysicalConstants.CODATA2018: μ_0

export mfd, mfd_z

"""
    mfd(superposition::Superposition, ρ, z)

The vectorial magnetic flux density of a superposition of coils in cylindrical coordinates.
"""
mfd(superposition::Superposition, ρ, z) = sum(mfd(coil, ρ, z) for coil in superposition.coils)

"""
    mfd(current_loop::CurrentLoop, ρ, z)

The vectorial magnetic flux density due to a current loop in cylindrical coordinates according to Ref. [1,2].

- [1] Simpson, James C. et al. “Simple Analytic Expressions for the Magnetic Field of a Circular Current Loop.” (2001).
- [2] Jang, Taehun, et al. "Off-axis magnetic fields of a circular loop and a solenoid for the electromagnetic induction of a magnetic pendulum." Journal of Physics Communications 5.6 (2021)
"""
function mfd(current_loop::CurrentLoop, ρ, z)
    I = current_loop.current
    R = current_loop.radius

    z = z + current_loop.height

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - α² / β^2

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = μ_0 * I / 2π

    Bρ = (C / (α² * β)) * ((R^2 + ρ^2 + z^2) * E - α² * K) * (z / ρ)
    Bz = (C / (α² * β)) * ((R^2 - ρ^2 - z^2) * E + α² * K)

    # Bρ diverges for ρ -> 0
    if iszero(ρ)
        Bρ = 0u"T"
    end

    # α becomes zero for z -> 0 when ρ -> R
    if iszero(z) && R ≈ ρ
        Bρ = 0u"T"
        Bz = 0u"T"
    end

    return [Bρ Bz]
end

mfd(c::Helical, ρ, z) = mfd(Superposition(c), ρ, z)

# https://de.wikipedia.org/wiki/Leiterschleife
function mfd_z(c::CurrentLoop, z)
    I = c.current
    R = c.radius

    Bz = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

    return [0u"T" Bz]
end

# https://en.wikipedia.org/wiki/Solenoid
function mfd_z(c::Helical, z)
    if (c.radial_turns > 1)
        throw(ArgumentError("Only solenoids are supported"))
    end
    if (!isapprox(z, c.height))
        throw(ArgumentError("Can only give the magnetic flux density inside the solenoid"))
    end

    I = c.current
    N = c.axial_turns
    L = c.length

    Bz = μ_0 * I * N / L

    return [0u"T" Bz]
end