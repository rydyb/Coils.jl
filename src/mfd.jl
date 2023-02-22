using Elliptic
using Unitful
using PhysicalConstants.CODATA2018: μ_0

export mfd

"""
    mfd(coil::CurrentInversion, ρ, z)

The vectorial magnetic flux density of a current inverted coil in cylindrical coordinates.
"""
#mfd(current_inversion::CurrentInversion, ρ, z) = -mfd(current_inversion.coil, ρ, z)

"""
    mfd(translation::Translation, ρ, z)

The vectorial magnetic flux density of a translated coil in cylindrical coordinates.
"""
#mfd(translation::Translation, ρ, z) = mfd(translation.coil, ρ, z - translation.axial_shift)

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
    if ρ == 0
        Bρ = 0
    end

    # α becomes zero for z -> 0 when ρ -> R
    if z == 0 && isapprox(R, ρ; rtol=1e-4)
        Bρ = 0
        Bz = 0
    end

    return [Bρ Bz]
end