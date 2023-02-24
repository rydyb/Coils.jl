export Coil, CurrentLoop, Pancake, Solenoid, Helical

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
    Helical(current, inner_radius, outer_radius, length, axial_turns, radial_turns, height)

A helical coil with a given current, inner radius, outer radius, height, number of axial turns, number of radial turns, and height centered at the origin.
"""
struct Helical{
    C<:Unitful.Current,
    IR<:Unitful.Length,
    OR<:Unitful.Length,
    L<:Unitful.Length,
    AT<:Unsigned,
    RT<:Unsigned,
    H<:Unitful.Length,
} <: Coil
    current::C
    inner_radius::IR
    outer_radius::OR
    length::L
    axial_turns::AT
    radial_turns::RT
    height::H
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
end

Base.:(==)(x::Superposition, y::Superposition) = x.coils == y.coils