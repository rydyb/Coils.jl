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
struct CurrentLoop <: Coil
    current::Unitful.Current
    radius::Unitful.Length
    height::Unitful.Length

    CurrentLoop(current::Unitful.Current, radius::Unitful.Length) = new(current, radius, 0u"m")
    CurrentLoop(current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length) = new(current, radius, height)
end

"""
    Pancake(current, inner_radius, outer_radius, turns, height)

A pancake coil with a given current, inner radius, outer radius, height and number of turns centered at the origin.
"""
struct Pancake <: Coil
    current::Unitful.Current
    inner_radius::Unitful.Length
    outer_radius::Unitful.Length
    turns::UInt8
    height::Unitful.Length

    Pancake(current::Unitful.Current, inner_radius::Unitful.Length, outer_radius::Unitful.Length, turns::UInt8) = new(current, inner_radius, outer_radius, turns, 0u"m")
end

"""
    Solenoid(current, radius, length, turns, height)

A solenoid coil with a given current, radius, length, height, and number of turns centered at the origin.
"""
struct Solenoid <: Coil
    current::Unitful.Current
    radius::Unitful.Length
    length::Unitful.Length
    turns::UInt8
    height::Unitful.Length

    Solenoid(current::Unitful.Current, radius::Unitful.Length, length::Unitful.Length, turns::UInt8) = new(current, radius, length, turns, 0u"m")
    Solenoid(current::Unitful.Current, radius::Unitful.Length, length::Unitful.Length, turns::UInt8, height::Unitful.Length) = new(current, radius, length, turns, height)
end

"""
    Helical(current, inner_radius, outer_radius, length, axial_turns, radial_turns, height)

A helical coil with a given current, inner radius, outer radius, height, number of axial turns, number of radial turns, and height centered at the origin.
"""
struct Helical <: Coil
    current::Unitful.Current
    inner_radius::Unitful.Length
    outer_radius::Unitful.Length
    length::Unitful.Length
    axial_turns::UInt8
    radial_turns::UInt8
    height::Unitful.Length

    Helical(current::Unitful.Current, inner_radius::Unitful.Length, outer_radius::Unitful.Length, length::Unitful.Length, axial_turns::UInt8, radial_turns::UInt8) = new(current, inner_radius, outer_radius, length, axial_turns, radial_turns, 0u"m")
    Helical(current::Unitful.Current, inner_radius::Unitful.Length, outer_radius::Unitful.Length, length::Unitful.Length, axial_turns::UInt8, radial_turns::UInt8, height::Unitful.Length) = new(current, inner_radius, outer_radius, length, axial_turns, radial_turns, height)
end

# solenoid and pancake are just special cases of the helical coil
convert(::Type{Helical}, c::Pancake) = Helical(c.current, c.inner_radius, c.outer_radius, 0u"m", UInt8(1), c.turns, c.height)
convert(::Type{Helical}, c::Solenoid) = Helical(c.current, c.radius, c.radius, c.length, c.turns, UInt8(1), c.height)

"""
    Virtual

An abstract type for a virtual coil.
"""
abstract type Virtual end

"""
    Superposition(coils::Vector{Coil})

A superposition of coils.
"""
struct Superposition <: Virtual
    coils::Vector{Coil}

    """
        Superposition(c::Helical)

    Represents a helical coil as a superposition of current loops.
    """
    function Superposition(c::Helical)
        coils = Vector{Coil}(undef, c.axial_turns * c.radial_turns)

        radial_width = c.outer_radius - c.inner_radius
        radial_increment = radial_width / (c.radial_turns - 1)
        axial_increment = c.length / (c.axial_turns - 1)

        for i in 1:c.radial_turns
            radius = c.inner_radius + radial_increment * (i - 1)

            for j in 1:c.axial_turns
                axial_shift = c.height - c.length / 2 + axial_increment * (j - 1)
                coils[(i-1)*c.axial_turns+j] = CurrentLoop(c.current, radius, axial_shift)
            end
        end

        return new(coils)
    end
    Superposition(c::Union{Pancake,Solenoid}) = Superposition(convert(Helical, c))
end

convert(::Type{Superposition}, c::Pancake) = Superposition(convert(Helical, c))
convert(::Type{Superposition}, c::Solenoid) = Superposition(convert(Helical, c))
convert(::Type{Superposition}, c::Helical) = Superposition(c)