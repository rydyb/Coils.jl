using Elliptic
using Unitful
using PhysicalConstants.CODATA2018: μ_0

μ₀ = ustrip(u"N/A^2", μ_0)

export mfd

# References
# [1] Simpson, James C. et al. “Simple Analytic Expressions for the Magnetic Field of a Circular Current Loop.” (2001).
# [2] Jang, Taehun, et al. "Off-axis magnetic fields of a circular loop and a solenoid for the electromagnetic induction of a magnetic pendulum." Journal of Physics Communications 5.6 (2021)

"""
    mfd(cl::CurrentLoop, ρ::Float64, z::Float64)

The vectorial magnetic flux density due to a current loop in cylindrical coordinates with the current loop centered around the origin according to Ref. [1,2].
"""
function mfd(cl::CurrentLoop, ρ::Float64, z::Float64)
    I = cl.current
    R = cl.radius

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - α² / β^2

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = μ₀ * I / 2π

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