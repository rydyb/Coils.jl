using Elliptic
using DynamicQuantities.Constants: mu_0
using LinearAlgebra: norm

export magnetic_flux_density

magnetic_flux_density(::AbstractCoil, args...) = throw(ErrorException("not implemented"))

function magnetic_flux_density(c::CircularLoop, ρ::AbstractQuantity, z::AbstractQuantity)
    R = c.radius
    I = c.current

    B0 = typeof(c.current)(0u"Gauss")

    if iszero(z) && R ≈ ρ
        return B0, B0, B0
    end

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - ustrip(α² / β^2)

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = mu_0 * I / typeof(c.current)(2π)

    # Bρ diverges for ρ -> 0
    if iszero(ρ)
        Bρ = B0
    else
        Bρ = (C / (α² * β)) * ((R^2 + ρ^2 + z^2) * E - α² * K) * (z / ρ)
    end

    Bz = (C / (α² * β)) * ((R^2 - ρ^2 - z^2) * E + α² * K)

    return Bρ, Bz
end

function magnetic_flux_density(
    c::CircularLoop,
    x::AbstractQuantity,
    y::AbstractQuantity,
    z::AbstractQuantity,
)
    Bρ, Bz = magnetic_flux_density(c, norm((x, y)), z)

    ρ = sqrt(x^2 + y^2)
    θ = atan(y, x)

    Bx = Bρ * cos(θ)
    By = Bρ * sin(θ)

    return Bx, By, Bz
end

function magnetic_flux_density(
    c::RectangularLoop,
    x::AbstractQuantity,
    y::AbstractQuantity,
    z::AbstractQuantity,
)
    I = c.current
    ax = c.height / 2
    ay = c.width / 2
    C = mu_0 * I / typeof(c.current)(4π)

    r1 = norm((x + ax, y + ay, z))
    r2 = norm((x - ax, y + ay, z))
    r3 = norm((x + ax, y - ay, z))
    r4 = norm((x - ax, y - ay, z))

    f(r, s) = 1 / (r * (r - s))

    Bx = f(r1, y + ay)
    Bx -= f(r2, y + ay)
    Bx -= f(r3, y - ay)
    Bx += f(r4, y - ay)
    Bx *= -C * z

    By = f(r1, x + ax)
    By -= f(r2, x - ax)
    By -= f(r3, x + ax)
    By += f(r4, x - ax)
    By *= -C * z

    Bz = (x + ax) * f(r1, y + ay)
    Bz += (y + ay) * f(r1, x + ax)
    Bz -= (x - ax) * f(r2, y + ay)
    Bz -= (y + ay) * f(r2, x - ax)
    Bz -= (x + ax) * f(r3, y - ay)
    Bz -= (y - ay) * f(r3, x + ax)
    Bz += (x - ax) * f(r4, y - ay)
    Bz += (y - ay) * f(r4, x - ax)
    Bz *= C

    return Bx, By, Bz
end

function magnetic_flux_density(c::Displace, x, y, z)
    return magnetic_flux_density(c.coil, x - c.x, y - c.y, z - c.z)
end

function magnetic_flux_density(c::Reverse, x, y, z)
    return magnetic_flux_density(c.coil, x, y, z) .* -1
end

function magnetic_flux_density(c::Superposition, x, y, z)
    Bx = 0.0u"Gauss"
    By = 0.0u"Gauss"
    Bz = 0.0u"Gauss"

    for coil in c.coils
        B = magnetic_flux_density(coil, x, y, z)
        Bx += B[1]
        By += B[2]
        Bz += B[3]
    end

    return Bx, By, Bz
end
