using Elliptic
using PhysicalConstants.CODATA2018: μ_0

export Coil, CurrentLoop, Pancake, Solenoid, Helical, Helmholtz, AntiHelmholtz, Superposition
export mfd, mfd_z
export conductor_coordinates, conductor_length

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

    z = z + current_loop.height

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

# https://de.wikipedia.org/wiki/Leiterschleife
function mfd_z(c::CurrentLoop, z)
    I = c.current
    R = c.radius

    Bz = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

    return upreferred.([0u"T" Bz])
end

"""
    Helical(current, inner_radius, outer_radius, length, axial_turns, radial_turns, height)

A helical coil with a given current, inner radius, outer radius, height, number of axial turns, number of radial turns, and height centered at the origin.
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

struct Helmholtz{
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
    separation::T5
    turns::T6
end

Helmholtz(;
    current::Unitful.Current,
    inner_radius::Unitful.Length = outer_radius,
    outer_radius::Unitful.Length = inner_radius,
    length::Unitful.Length = 0u"m",
    axial_turns::Unsigned = UInt8(1),
    radial_turns::Unsigned = UInt8(1),
    separation::Unitful.Length = (outer_radius + inner_radius) / 2,
) = Helmholtz(current, inner_radius, outer_radius, length, separation, (radial_turns, axial_turns))

# https://en.wikipedia.org/wiki/Helmholtz_coil
function mfd_z(c::Helmholtz, z)
    if (!isapprox(z, 0u"m"))
        throw(ArgumentError("Can only give the magnetic flux density at the origin"))
    end

    I = c.current
    N = c.turns[1] * c.turns[2]
    R = (c.inner_radius + c.outer_radius) / 2

    Bz = (4 / 5)^(3 / 2) * μ_0 * I * N / R

    return upreferred.([0u"T" Bz])
end

struct AntiHelmholtz{
    T1<:Unitful.Current,
    T2<:Unitful.Length,
    T3<:Unitful.Length,
    T4<:Unitful.Length,
    T5<:Unitful.Length,
    T6<:Tuple{Unsigned,Unsigned},
} <: Coil
    top_current::T1
    bottom_current::T1
    inner_radius::T2
    outer_radius::T3
    length::T4
    separation::T5
    turns::T6
end

AntiHelmholtz(;
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    length::Unitful.Length,
    axial_turns::Unsigned = UInt8(1),
    radial_turns::Unsigned = UInt8(1),
    separation::Unitful.Length = √3(outer_radius + inner_radius) / 2,
) = AntiHelmholtz(
    current,
    -current,
    inner_radius,
    outer_radius,
    length,
    separation,
    (radial_turns, axial_turns),
)


"""
    Virtual

An abstract type for a virtual coil.
"""
abstract type Virtual end

"""
    Superposition(coils::Vector{Coil})

A superposition of coils.
"""
struct Superposition{T<:Coil} <: Virtual
    coils::Vector{T}

    Superposition(coils::Vector{T}) where {T<:Coil} = new{T}(coils)

    """
        Superposition(c::Helical)

    Represents a helical coil as a superposition of current loops.
    """
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

    function Superposition(c::Helmholtz)
        top_coil = Helical(
            current = c.current,
            inner_radius = c.inner_radius,
            outer_radius = c.outer_radius,
            length = c.length,
            radial_turns = c.turns[1],
            axial_turns = c.turns[2],
            height = c.separation / 2,
        )
        bottom_coil = Helical(
            current = c.current,
            inner_radius = c.inner_radius,
            outer_radius = c.outer_radius,
            length = c.length,
            radial_turns = c.turns[1],
            axial_turns = c.turns[2],
            height = -c.separation / 2,
        )

        top_loops = Superposition(top_coil).coils
        bottom_loops = Superposition(bottom_coil).coils

        return new{CurrentLoop}(vcat(top_loops, bottom_loops))
    end

    function Superposition(c::AntiHelmholtz)
        top_coil = Helical(
            current = c.top_current,
            inner_radius = c.inner_radius,
            outer_radius = c.outer_radius,
            length = c.length,
            radial_turns = c.turns[1],
            axial_turns = c.turns[2],
            height = c.separation / 2,
        )
        bottom_coil = Helical(
            current = c.bottom_current,
            inner_radius = c.inner_radius,
            outer_radius = c.outer_radius,
            length = c.length,
            radial_turns = c.turns[1],
            axial_turns = c.turns[2],
            height = -c.separation / 2,
        )

        top_loops = Superposition(top_coil).coils
        bottom_loops = Superposition(bottom_coil).coils

        return new{CurrentLoop}(vcat(top_loops, bottom_loops))
    end
end

Base.:(==)(x::Superposition, y::Superposition) = x.coils == y.coils

"""
    mfd(superposition::Superposition, ρ, z)

The vectorial magnetic flux density of a superposition of coils in cylindrical coordinates.
"""
mfd(superposition::Superposition, ρ, z) = sum(mfd(coil, ρ, z) for coil in superposition.coils)
mfd(c::Helical, ρ, z) = mfd(Superposition(c), ρ, z)
mfd(c::Helmholtz, ρ, z) = mfd(Superposition(c), ρ, z)
mfd(c::AntiHelmholtz, ρ, z) = mfd(Superposition(c), ρ, z)

conductor_coordinates(c::CurrentLoop) = [[c.radius c.height]]
conductor_coordinates(sp::Superposition) = [ρz for c in sp.coils for ρz in conductor_coordinates(c)]
conductor_coordinates(c::Helical) = conductor_coordinates(Superposition(c))
conductor_coordinates(c::Helmholtz) = conductor_coordinates(Superposition(c))
conductor_coordinates(c::AntiHelmholtz) = conductor_coordinates(Superposition(c))

conductor_length(c::CurrentLoop) = 2π * c.radius
conductor_length(sp::Superposition) = sum(conductor_length(c) for c in sp.coils)
conductor_length(c::Helical) = conductor_length(Superposition(c))
