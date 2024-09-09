using Elliptic
using DynamicQuantities.Constants: mu_0
using LinearAlgebra: norm

export magnetic_flux_density

function magnetic_flux_density(c::CircularLoop, ρ::AbstractQuantity, z::AbstractQuantity)
    R = qconvert(c.radius, u"mm")
    I = qconvert(c.current, u"A")

    B0 = 0.0u"Gauss"

    if iszero(z) && R ≈ ρ
        return (B0, B0, B0)
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

    return uconvert.(us"Gauss", (Bρ, B0, Bz))
end

function magnetic_flux_density(c::CircularLoop, ρ::Number, z::Number)
    return ustrip.(magnetic_flux_density(c, ρ * u"mm", z * u"mm"))
end

function magnetic_flux_density(c::CircularLoop, x::AbstractQuantity, y::AbstractQuantity, z::AbstractQuantity)
    Bρ, Bz = magnetic_flux_density(c, norm((x, y)), z)
end

function magnetic_flux_density(v::Vector{CircularLoop}, x, y, z)
    return sum(magnetic_flux_density(c, x, y, z) for c in v)
end

function magnetic_flux_density(r::RectangularLoop, x::AbstractQuantity, y::AbstractQuantity, z::AbstractQuantity)
    I = qconvert(r.current, u"A")

    ax = r.height / 2
    ay = r.width / 2
    C = mu_0 * I / typeof(r.current)(4π)

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

    return uconvert.(us"Gauss", (Bx, By, Bz))
end

function magnetic_flux_density(r::RectangularLoop, x::Number, y::Number, z::Number)
    return ustrip.(magnetic_flux_density(r, x * u"mm", y * u"mm", z * u"mm"))
end

function magnetic_flux_density(v::Vector{RectangularLoop}, x, y, z)
    return sum(magnetic_flux_density(r, x, y, z) for r in v)
end

function magnetic_flux_density(t::Translation, x, y, z)
    x0 = t.vector[1]
    y0 = t.vector[2]
    z0 = t.vector[3]

    x′ = x - x0
    y′ = y - y0
    z′ = z - z0

    B = magnetic_flux_density(t.coil, x′, y′, z′)

    if t.coil isa CircularLoop
        ρ = sqrt(x′^2 + y′^2)
        if !iszero(ρ)
            θ = atan(y′, x′)
            Bρ = B[1]
            Bz = B[2]
            Bx = Bρ * cos(θ)
            By = Bρ * sin(θ)
            return [Bx, By, Bz]
        end
    end

    return B
end
