using Elliptic
using Unitful
using PhysicalConstants.CODATA2018: μ_0
using LinearAlgebra

export RectangularLoop
export mfd

struct RectangularLoop{T1<:Unitful.Current,T2<:Unitful.Length,T3<:Unitful.Length} <: Conductor
    current::T1
    width::T2
    height::T3

    function RectangularLoop(
        current::T1,
        width::T2,
        height::T3,
    ) where {T1<:Unitful.Current,T2<:Unitful.Length,T3<:Unitful.Length}
        @assert width > 0u"m" && height > 0u"m" "width and height must be positive"
        new(current, width, height)
    end
end

function conductor_length(c::RectangularLoop)
    return 2 * (c.width + c.height)
end

function magnetic_flux_density(c::RectangularLoop, x, y, z)
    I = c.current
    C = μ_0 * I / 4π

    ax = c.height / 2
    ay = c.width / 2

    r = [x, y, z]

    r1 = norm(r .+ [ax, ay, 0])
    r2 = norm(r .+ [-ax, ay, 0])
    r3 = norm(r .+ [ax, -ay, 0])
    r4 = norm(r .+ [-ax, -ay, 0])

    f(u, v) =
        1 / (r1 * (r1 - u - v)) - 1 / (r2 * (r2 - u - v)) - 1 / (r3 * (r3 - u + v)) +
        1 / (r4 * (r4 - u + v))

    Bx = -C * z * f(y, ay)
    By = -C * z * f(x, ax)
    Bz = 0.0u"Gauss"


    return uconvert.(u"Gauss", [Bx, By, Bz])
end
