using Elliptic
using DynamicQuantities.Constants: mu_0
using LinearAlgebra: norm

export magnetic_flux_density

function magnetic_flux_density(c::CircularLoop, ρ, z)
    I = qconvert(c.current, u"A")
    R = qconvert(c.radius, u"mm")

    ρ = qconvert(ρ, u"mm")
    z = qconvert(z, u"mm")

    if iszero(z) && R ≈ ρ
        return [0.0u"Gauss", 0.0u"Gauss"]
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
    I = qconvert(r.current, u"A")
    ax = qconvert(r.height / 2, u"mm")
    ay = qconvert(r.width / 2, u"mm")
    C = mu_0 * I / 4π

    x = qconvert(x, u"mm")
    y = qconvert(y, u"mm")
    z = qconvert(z, u"mm")

    r1 = norm([x + ax, y + ay, z])
    r2 = norm([x - ax, y + ay, z])
    r3 = norm([x + ax, y - ay, z])
    r4 = norm([x - ax, y - ay, z])

    f(r, s) = 1 / (r * (r - s))

    Bx = -C * z * sum([
        f(r1, y + ay)
        -f(r2, y + ay)
        -f(r3, y - ay)
        +f(r4, y - ay)
    ])

    By = -C * z * sum([
        f(r1, x + ax)
        -f(r2, x - ax)
        -f(r3, x + ax)
        +f(r4, x - ax)
    ])

    Bz =
        C * sum([
            (x + ax) * f(r1, y + ay),
            +(y + ay) * f(r1, x + ax),
            -(x - ax) * f(r2, y + ay),
            -(y + ay) * f(r2, x - ax),
            -(x + ax) * f(r3, y - ay),
            -(y - ay) * f(r3, x + ax),
            +(x - ax) * f(r4, y - ay),
            +(y - ay) * f(r4, x - ax),
        ])

    Bx = qconvert(Bx, u"Gauss")
    By = qconvert(By, u"Gauss")
    Bz = qconvert(Bz, u"Gauss")

    return [Bx, By, Bz]
end
