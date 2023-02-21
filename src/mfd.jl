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

# Arguments
- `cl::CurrentLoop`: The current loop.
- `ρ::Float64`: The radial coordinate in meters.
- `z::Float64`: The axial coordinate in meters.

# Returns
- `Vector{Float64}`: The vectorial magnetic flux density in Gauss.
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

    return [Bρ Bz] ./ 1e-4
end

"""
    mfd(ao::AxialOffset, ρ::Float64, z::Float64)

The vectorial magnetic flux density due to a coil shifted axialy with respect to the origin.

# Arguments
- `ao::AxialOffset`: The coil shifted axialy with respect to the origin.
- `ρ::Float64`: The radial coordinate in meters.
- `z::Float64`: The axial coordinate in meters.

# Returns
- `Vector{Float64}`: The vectorial magnetic flux density in Gauss.
"""
function mfd(ao::AxialOffset, ρ::Float64, z::Float64)
    z₀ = ao.offset

    return mfd(ao.coil, ρ, z - z₀)
end

"""
    mfd(sp::Superposition, ρ::Float64, z::Float64)

The vectorial magnetic flux density due to a superposition of coils.

# Arguments
- `sp::Superposition`: The coil made of superpositions of coils.
- `ρ::Float64`: The radial coordinate in meters.
- `z::Float64`: The axial coordinate in meters.

# Returns
- `Vector{Float64}`: The vectorial magnetic flux density in Gauss.
"""
function mfd(sp::Superposition, ρ::Float64, z::Float64)
    B = [0 0]

    for coil in sp.coils
        B += mfd(coil, ρ, z)
    end

    return B
end

"""
    mfd(rc::ReverseCurrent, ρ::Float64, z::Float64)

The vectorial magnetic flux density due to a coil with a reversed current.

# Arguments
- `rc::ReverseCurrent`: The coil with a reversed current.
- `ρ::Float64`: The radial coordinate in meters.
- `z::Float64`: The axial coordinate in meters.

# Returns
- `Vector{Float64}`: The vectorial magnetic flux density in Gauss.
"""
function mfd(rc::ReverseCurrent, ρ::Float64, z::Float64)
    return -mfd(rc.coil, ρ, z)
end