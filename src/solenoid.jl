export Helical, Pancake, Solenoid

struct Helical{T1<:Unitful.Current,T2<:Unitful.Length,T3<:Unitful.Length,T4<:Unsigned} <: Conductor
    current::T1
    radius::T2
    length::T3
    radial_turns::T4
    axial_turns::T4

    function Helical(;
        current::T1,
        radius::T2,
        length::T3,
        radial_turns::T4,
        axial_turns::T4,
    ) where {T1<:Unitful.Current,T2<:Unitful.Length,T3<:Unitful.Length}
        @assert radius >= 0u"m" "radius must be positive"
        @assert length >= 0u"m" "length must be positive"
        @assert radial_turns >= 0 "radial turns must not be negative"
        @assert axial_turns >= 0 "axial turns must not be negative"

        new(current, width, height, radial_turns, axial_turns)
    end
end

function conductor_length(c::Helical)
    return 2π * c.radius * c.axial_turns * c.axial_turns
end

Pancake(; current::Unitful.Current, radius::Unitful.Length, turns::Unsigned) = Helical(
    current = current,
    radius = radius,
    length = 0u"m",
    radial_turns = turns,
    axial_turns = UInt8(1),
)

Solenoid(;
    current::Unitful.Current,
    radius::Unitful.Length,
    length::Unitful.Length,
    turns::Unsigned,
) = Helical(
    current = current,
    radius = radius,
    length = length,
    radial_turns = UInt8(1),
    axial_turns = turns,
)

function magnetic_flux_density(c::Helical, z)
    if !iszero(z)
        throw(ArgumentError("magnetic field density is only defined at the center of the solenoid"))
    end

    if (c.radial_turns > 1)
        throw(ArgumentError("magnetic field density is only defined for a single turn solenoid"))
    end

    I = c.current
    R = c.radius
    N = c.axial_turns
    L = c.length

    Bρ = 0.0u"Gauss"
    Bz = μ_0 * N * I / √((2R)^2 + L^2)

    return uconvert.(u"Gauss", [Bρ, Bz])
end

function inductance(c::Helical)
    R = c.radius
    N = c.axial_turns
    L = c.length

    return uconvert(u"μH", π * μ_0 * N^2 * R^2 / (L + 0.9R))
end