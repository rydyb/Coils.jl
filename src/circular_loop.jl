using Elliptic
using Unitful
using PhysicalConstants.CODATA2018: μ_0

export CircularLoop
export mfd
export length

struct CircularLoop{T1<:Unitful.Current,T2<:Unitful.Length} <: Conductor
    current::T1
    radius::T2

    function CircularLoop(current::T1, radius::T2) where {T1<:Unitful.Current,T2<:Unitful.Length}
        @assert radius > 0u"m" "radius must be positive"
        new(current, radius)
    end
end

function conductor_length(c::CircularLoop)
    return 2π * c.radius
end

function magnetic_flux_density(c::CircularLoop, ρ, z)
    I = c.current
    R = c.radius

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