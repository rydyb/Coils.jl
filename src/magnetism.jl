using Elliptic
using PhysicalConstants.CODATA2018: μ_0

export Coil, CurrentLoop, Pancake, Solenoid, Helical, Helmholtz, AntiHelmholtz
export mfd, mfd_z

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

CurrentLoop(current::Unitful.Current, radius::Unitful.Length) = CurrentLoop(current, radius, 0u"m")

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
    T5<:Unsigned,
    T6<:Unsigned,
    T7<:Unitful.Length,
} <: Coil
    current::T1
    inner_radius::T2
    outer_radius::T3
    length::T4
    axial_turns::T5
    radial_turns::T6
    height::T7
end

Helical(
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    length::Unitful.Length,
    axial_turns::Unsigned,
    radial_turns::Unsigned,
) = Helical(current, inner_radius, outer_radius, length, axial_turns, radial_turns, 0u"m")

Pancake(
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    turns::Unsigned,
) = Helical(current, inner_radius, outer_radius, 0u"m", UInt8(1), turns)
Pancake(
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    turns::Unsigned,
    height::Unitful.Length,
) = Helical(current, inner_radius, outer_radius, 0u"m", UInt8(1), turns, height)

Solenoid(
    current::Unitful.Current,
    radius::Unitful.Length,
    length::Unitful.Length,
    turns::Unsigned,
    height::Unitful.Length,
) = Helical(current, radius, radius, length, turns, UInt8(1), height)
Solenoid(
    current::Unitful.Current,
    radius::Unitful.Length,
    length::Unitful.Length,
    turns::Unsigned,
) = Helical(current, radius, radius, length, turns, UInt8(1))


# https://en.wikipedia.org/wiki/Solenoid
function mfd_z(c::Helical, z)
    if (c.radial_turns > 1)
        throw(ArgumentError("Only solenoids are supported"))
    end
    if (!isapprox(z, c.height))
        throw(ArgumentError("Can only give the magnetic flux density inside the solenoid"))
    end

    I = c.current
    N = c.axial_turns
    L = c.length

    Bz = μ_0 * I * N / L

    return upreferred.([0u"T" Bz])
end

struct Helmholtz{
    T1<:Unitful.Current,
    T2<:Unitful.Length,
    T3<:Unitful.Length,
    T4<:Unitful.Length,
    T5<:Unsigned,
    T6<:Unsigned,
    T7<:Unitful.Length,
} <: Coil
    current::T1
    inner_radius::T2
    outer_radius::T3
    length::T4
    axial_turns::T5
    radial_turns::T6
    separation::T7
end

Helmholtz(
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    length::Unitful.Length,
    axial_turns::Unsigned,
    radial_turns::Unsigned,
) = Helmholtz(
    current,
    inner_radius,
    outer_radius,
    length,
    axial_turns,
    radial_turns,
    (outer_radius + inner_radius) / 2,
)

# https://en.wikipedia.org/wiki/Helmholtz_coil
function mfd_z(c::Helmholtz, z)
    if (!isapprox(z, 0u"m"))
        throw(ArgumentError("Can only give the magnetic flux density at the origin"))
    end

    total_turns = c.axial_turns * c.radial_turns
    effective_radius = (c.inner_radius + c.outer_radius) / 2

    Bz = (4 / 5)^(3 / 2) * μ_0 * total_turns * c.current / effective_radius

    return upreferred.([0u"T" Bz])
end

struct AntiHelmholtz{
    T1<:Unitful.Current,
    T2<:Unitful.Length,
    T3<:Unitful.Length,
    T4<:Unitful.Length,
    T5<:Unsigned,
    T6<:Unsigned,
    T7<:Unitful.Length,
} <: Coil
    top_current::T1
    bottom_current::T1
    inner_radius::T2
    outer_radius::T3
    length::T4
    axial_turns::T5
    radial_turns::T6
    separation::T7
end

AntiHelmholtz(
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    length::Unitful.Length,
    axial_turns::Unsigned,
    radial_turns::Unsigned,
    separation::Unitful.Length,
) = AntiHelmholtz(
    current,
    -current,
    inner_radius,
    outer_radius,
    length,
    axial_turns,
    radial_turns,
    separation,
)

AntiHelmholtz(
    current::Unitful.Current,
    inner_radius::Unitful.Length,
    outer_radius::Unitful.Length,
    length::Unitful.Length,
    axial_turns::Unsigned,
    radial_turns::Unsigned,
) = AntiHelmholtz(
    current,
    inner_radius,
    outer_radius,
    length,
    axial_turns,
    radial_turns,
    √3(outer_radius + inner_radius) / 2,
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
        coils = Vector{CurrentLoop}(undef, c.axial_turns * c.radial_turns)

        for i = 1:c.radial_turns
            if c.radial_turns == 1
                radius = (c.inner_radius + c.outer_radius) / 2
            else
                radius =
                    c.inner_radius +
                    (c.outer_radius - c.inner_radius) * (i - 1) / (c.radial_turns - 1)
            end

            for j = 1:c.axial_turns
                if c.axial_turns == 1
                    height = c.height
                else
                    height = c.height - c.length / 2 + c.length * (j - 1) / (c.axial_turns - 1)
                end

                coils[(i-1)*c.axial_turns+j] = CurrentLoop(c.current, radius, height)
            end
        end

        return new{CurrentLoop}(coils)
    end

    function Superposition(c::Helmholtz)
        top_coil = Helical(
            c.current,
            c.inner_radius,
            c.outer_radius,
            c.length,
            c.axial_turns,
            c.radial_turns,
            c.separation / 2,
        )
        bottom_coil = Helical(
            c.current,
            c.inner_radius,
            c.outer_radius,
            c.length,
            c.axial_turns,
            c.radial_turns,
            -c.separation / 2,
        )

        top_loops = Superposition(top_coil).coils
        bottom_loops = Superposition(bottom_coil).coils

        return new{CurrentLoop}(vcat(top_loops, bottom_loops))
    end

    function Superposition(c::AntiHelmholtz)
        top_coil = Helical(
            c.top_current,
            c.inner_radius,
            c.outer_radius,
            c.length,
            c.axial_turns,
            c.radial_turns,
            c.separation / 2,
        )
        bottom_coil = Helical(
            c.bottom_current,
            c.inner_radius,
            c.outer_radius,
            c.length,
            c.axial_turns,
            c.radial_turns,
            -c.separation / 2,
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

wires(c::CurrentLoop) = [[c.radius c.height]]
wires(sp::Superposition) = [ρz for c in sp.coils for ρz in wires(c)]
wires(c::Helical) = wires(Superposition(c))
wires(c::Helmholtz) = wires(Superposition(c))
wires(c::AntiHelmholtz) = wires(Superposition(c))