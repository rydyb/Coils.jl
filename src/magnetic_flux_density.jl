using Elliptic
using DynamicQuantities.Constants: mu_0
using LinearAlgebra: norm

export magnetic_flux_density

function magnetic_flux_density(c::CircularLoop, ρ, z)
    I = c.current
    R = c.radius

    if iszero(z) && R ≈ ρ
        return [0.0, 0.0]
    end

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - ustrip(α² / β^2)

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = mu_0 * I / 2π

    # Bρ diverges for ρ -> 0
    if iszero(ρ)
        Bρ = 0.0u"Gauss"
    else
        Bρ = (C / (α² * β)) * ((R^2 + ρ^2 + z^2) * E - α² * K) * (z / ρ)
    end

    Bz = (C / (α² * β)) * ((R^2 - ρ^2 - z^2) * E + α² * K)

    return uconvert.(us"Gauss", [Bρ, Bz])
end

function magnetic_flux_density(r::RectangularLoop, x, y, z)
    I = r.current
    C = mu_0 * I / 4π

    ax = r.height / 2
    ay = r.width / 2

    r = [x, y, z]

    r1 = norm(r .+ [ax, ay, 0])
    r2 = norm(r .+ [-ax, ay, 0])
    r3 = norm(r .+ [ax, -ay, 0])
    r4 = norm(r .+ [-ax, -ay, 0])

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

    return uconvert.(us"Gauss", [Bx, By, Bz])
end
