using Elliptic
using PhysicalConstants.CODATA2018: μ_0

export Coil, CurrentLoop, Pancake, Solenoid, Helical
export Superposition, CoilPair, Helmholtz, AntiHelmholtz
export mfd, mfd_z
export conductor_coordinates, conductor_length
export ishelmholtz, isantihelmholtz
export inductance

"""
    Coil

An abstract type for a magnetic coil.
"""
abstract type Coil end

"""
    CurrentLoop(current, radius, height)

A current loop with a given current, radius, and height centered at the origin.
"""
struct CurrentLoop{C<:Unitful.Current,R<:Unitful.Length,H<:Unitful.Length} <: Coil
    current::C
    radius::R
    height::H
end

CurrentLoop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u"m") =
    CurrentLoop(current, radius, height)

"""
    mfd(current_loop::CurrentLoop, ρ, z)

The vectorial magnetic flux density due to a current loop in cylindrical coordinates according to Ref. [1,2].

- [1] Simpson, James C. et al. “Simple Analytic Expressions for the Magnetic Field of a Circular Current Loop.” (2001).
- [2] Jang, Taehun, et al. "Off-axis magnetic fields of a circular loop and a solenoid for the electromagnetic induction of a magnetic pendulum." Journal of Physics Communications 5.6 (2021)
"""
function mfd(current_loop::CurrentLoop, ρ, z)
    I = current_loop.current
    R = current_loop.radius

    z = z - current_loop.height

    # α becomes zero for z -> 0 when ρ -> R
    if iszero(z) && R ≈ ρ
        return [0u"T" 0u"T"]
    end

    α² = R^2 + ρ^2 + z^2 - 2R * ρ
    β = √(R^2 + ρ^2 + z^2 + 2R * ρ)

    k² = 1 - α² / β^2

    E = Elliptic.E(k²)
    K = Elliptic.K(k²)

    C = μ_0 * I / 2π

    # Bρ diverges for ρ -> 0
    if iszero(ρ)
        Bρ = 0u"T"
    else
        Bρ = (C / (α² * β)) * ((R^2 + ρ^2 + z^2) * E - α² * K) * (z / ρ)
    end

    Bz = (C / (α² * β)) * ((R^2 - ρ^2 - z^2) * E + α² * K)

    return upreferred.([Bρ Bz])
end

"""
    mfd_z(current_loop::CurrentLoop, z)

The vectorial magnetic flux density on the z-axis due to a current loop in cylindrical coordinates.
"""
# https://de.wikipedia.org/wiki/Leiterschleife
function mfd_z(c::CurrentLoop, z)
    I = c.current
    R = c.radius

    Bz = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

    return upreferred.([0u"T" Bz])
end

conductor_coordinates(c::CurrentLoop) = [[c.radius c.height]]
conductor_length(c::CurrentLoop) = 2π * c.radius

"""
    Helical

A helical coil.
"""
struct Helical{
    T1<:Unitful.Current,
    T2<:Unitful.Length,
    T3<:Unitful.Length,
    T4<:Unitful.Length,
    T5<:Unitful.Length,
    T6<:Tuple{Unsigned,Unsigned},
} <: Coil
    current::T1
    inner_radius::T2
    outer_radius::T3
    length::T4
    height::T5
    turns::T6
end

Helical(;
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    length::Unitful.Length,
    axial_turns::Unsigned = UInt8(1),
    radial_turns::Unsigned = UInt8(1),
    height::Unitful.Length = 0u"m",
) = Helical(current, inner_radius, outer_radius, length, height, (radial_turns, axial_turns))

"""
    Pancake(current, inner_radius, outer_radius, turns, height)

Returns a helical coil with a pancake shape.
"""
Pancake(;
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    turns::Unsigned,
    height::Unitful.Length = 0u"m",
) = Helical(
    current = current,
    inner_radius = inner_radius,
    outer_radius = outer_radius,
    length = 0u"m",
    height = height,
    radial_turns = turns,
)

"""
    Solenoid(current, radius, length, turns, height)

Returns a helical coil with a solenoid shape.
"""
Solenoid(;
    current::Unitful.Current,
    radius::Unitful.Length,
    length::Unitful.Length,
    height::Unitful.Length = 0u"m",
    turns::Unsigned,
) = Helical(
    current = current,
    inner_radius = radius,
    outer_radius = radius,
    length = length,
    height = height,
    axial_turns = turns,
)

"""
    mfd(c::Helical, ρ, z)

The vectorial magnetic flux density due to a helical coil in cylindrical coordinates approximated by superposition of current loops.
"""
mfd(c::Helical, ρ, z) = mfd(Superposition(c), ρ, z)

"""
    mfd_z(c::Helical, z)

The vectorial magnetic flux density on the z-axis due to a solenoid coil in cylindrical coordinates.
"""
# https://en.wikipedia.org/wiki/Solenoid
function mfd_z(c::Helical, z)
    if (c.turns[1] > 1)
        throw(ArgumentError("Only solenoids are supported"))
    end
    if (!isapprox(z, c.height))
        throw(ArgumentError("Can only give the magnetic flux density inside the solenoid"))
    end

    I = c.current
    N = c.turns[2]
    L = c.length

    Bz = μ_0 * I * N / L

    return upreferred.([0u"T" Bz])
end

conductor_coordinates(c::Helical) = conductor_coordinates(Superposition(c))
conductor_length(c::Helical) = conductor_length(Superposition(c))

"""
    CoilPair

A pair of coils with the symmetry axis aligned.
"""
struct CoilPair{T<:Coil}
    top::T
    bottom::T
end

"""
    mfd(c::CoilPair, ρ, z)

The vectorial magnetic flux density due to a coil pair in cylindrical coordinates.
"""
mfd(c::CoilPair, ρ, z) = mfd(c.top, ρ, z) + mfd(c.bottom, ρ, z)

"""
    Helmholtz(coil, separation)

Returns a pair of coils in Helmholtz-like configuration.
"""
function Helmholtz(;
    coil::Helical,
    separation::Unitful.Length = (coil.outer_radius + coil.inner_radius) / 2,
)
    top = Helical(
        current = coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height + separation / 2,
        radial_turns = coil.turns[1],
        axial_turns = coil.turns[2],
    )
    bottom = Helical(
        current = coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height - separation / 2,
        radial_turns = coil.turns[1],
        axial_turns = coil.turns[2],
    )

    return CoilPair(top, bottom)
end

"""
    AntiHelmholtz(coil, separation)

Returns a pair of coils in anti-Helmholtz-like configuration.
"""
function AntiHelmholtz(;
    coil::Helical,
    separation::Unitful.Length = √3 * (coil.outer_radius + coil.inner_radius) / 2,
)
    top = Helical(
        current = coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height + separation / 2,
        radial_turns = coil.turns[1],
        axial_turns = coil.turns[2],
    )
    bottom = Helical(
        current = -coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height - separation / 2,
        radial_turns = coil.turns[1],
        axial_turns = coil.turns[2],
    )

    return CoilPair(top, bottom)
end

"""
    mfd_z(cp::CoilPair, z)

The vectorial magnetic flux density on the z-axis due to a Helmholtz-like coil pair in cylindrical coordinates.
"""
# https://en.wikipedia.org/wiki/Helmholtz_coil
function mfd_z(cp::CoilPair, z)
    if (!isapprox(z, 0u"m"))
        throw(ArgumentError("Can only give the magnetic flux density at the origin"))
    end
    # TODO: throw error if the coils are not the same
    if ishelmholtz(cp)
        throw(ArgumentError("Can only give the magnetic flux density for equal coils"))
    end

    c = cp.top
    I = c.current
    N = c.turns[1] * c.turns[2]
    R = (c.inner_radius + c.outer_radius) / 2

    Bz = (4 / 5)^(3 / 2) * μ_0 * I * N / R

    return upreferred.([0u"T" Bz])
end

function ishelmholtz(cp::CoilPair)
    return cp.top.current != cp.bottom.current ||
           cp.top.turns != cp.bottom.turns ||
           cp.top.length != cp.bottom.length ||
           cp.top.inner_radius != cp.bottom.inner_radius ||
           cp.top.outer_radius != cp.bottom.outer_radius
end

function isantihelmholtz(cp::CoilPair)
    return cp.top.current != -cp.bottom.current ||
           cp.top.turns != cp.bottom.turns ||
           cp.top.length != cp.bottom.length ||
           cp.top.inner_radius != cp.bottom.inner_radius ||
           cp.top.outer_radius != cp.bottom.outer_radius
end

function inductance(cp::CoilPair)
    N = Int(cp.top.turns[1]) * Int(cp.top.turns[2])
    R = (cp.top.inner_radius + cp.top.outer_radius) / 2
    L = cp.top.length

    C = 2μ_0 * R * N^2
    L1 = π * R / (L + 2R / 2.2)
    L2 = 4.941 / 4π

    if ishelmholtz(cp)
        return C * (L1 + L2)
    end

    if isantihelmholtz(cp)
        return C * (L1 - L2)
    end

    throw(ArgumentError("Can only give the inductance for Helmholtz or anti-Helmholtz coils"))
end

conductor_coordinates(c::CoilPair) =
    cat(conductor_coordinates(c.top), conductor_coordinates(c.bottom), dims = 1)
conductor_length(c::CoilPair) = conductor_length(c.top) + conductor_length(c.bottom)

"""
    Superposition(coils)

A superposition of current loops. Useful to approximate the magnetic flux densities of more complex coils.
"""
struct Superposition{T<:CurrentLoop}
    coils::Vector{T}

    Superposition(coils::Vector{T}) where {T<:Coil} = new{T}(coils)

    function Superposition(c::Helical)
        Nρ = c.turns[1]
        Nz = c.turns[2]

        coils = Vector{CurrentLoop}(undef, Nρ * Nz)

        I = c.current
        H = c.height
        L = c.length
        W = c.outer_radius - c.inner_radius
        Rin = c.inner_radius
        Rout = c.outer_radius
        Reff = (Rin + Rout) / 2

        for i = 1:Nρ
            if Nρ == 1
                R = Reff
            else
                R = Rin + (W / 1) * (i - 1) / (Nρ - 1)
            end

            for j = 1:Nz
                if Nz == 1
                    h = H
                else
                    h = H - L / 2 + L * (j - 1) / (Nz - 1)
                end

                coils[(i-1)*Nz+j] = CurrentLoop(current = I, radius = R, height = h)
            end
        end

        return new{CurrentLoop}(coils)
    end
end

Base.:(==)(x::Superposition, y::Superposition) = x.coils == y.coils

mfd(superposition::Superposition, ρ, z) = sum(mfd(coil, ρ, z) for coil in superposition.coils)

conductor_coordinates(sp::Superposition) = [ρz for c in sp.coils for ρz in conductor_coordinates(c)]
conductor_length(sp::Superposition) = sum(conductor_length(c) for c in sp.coils)
