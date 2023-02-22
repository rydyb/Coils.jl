export Coil, CurrentLoop, AxialOffset, ReverseCurrent, Superposition

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
end

"""
    PancakeCoil(current, inner_radius, outer_radius, turns, height)

A pancake coil with a given current, inner radius, outer radius, height and number of turns centered at the origin.
"""
struct PancakeCoil <: Coil
    current::Unitful.Current
    inner_radius::Unitful.Length
    outer_radius::Unitful.Length
    turns::UInt8
    height::Unitful.Length

    PancakeCoil(current::Unitful.Current, inner_radius::Unitful.Length, outer_radius::Unitful.Length, turns::UInt8) = new(current, inner_radius, outer_radius, turns, 0u"m")
end

"""
    SolenoidCoil(current, radius, length, turns, height)

A solenoid coil with a given current, radius, length, height, and number of turns centered at the origin.
"""
struct SolenoidCoil <: Coil
    current::Unitful.Current
    radius::Unitful.Length
    length::Unitful.Length
    turns::UInt8
    height::Unitful.Length

    SolenoidCoil(current::Unitful.Current, radius::Unitful.Length, length::Unitful.Length, turns::UInt8) = new(current, radius, length, turns, 0u"m")
end

"""
    HelicalCoil(current, inner_radius, outer_radius, length, axial_turns, radial_turns, height)

A helical coil with a given current, inner radius, outer radius, height, number of axial turns, number of radial turns, and height centered at the origin.
"""
struct HelicalCoil <: Coil
    current::Unitful.Current
    inner_radius::Unitful.Length
    outer_radius::Unitful.Length
    length::Unitful.Length
    axial_turns::UInt8
    radial_turns::UInt8
    height::Unitful.Length
end

"""
    CoilOperation

An abstract type for a coil operation
"""
abstract type CoilOperation end

"""
    Superposition(coils::Vector{Coil})

A superposition of coils.
"""
struct Superposition <: CoilOperation
    coils::Vector{Coil}
end

"""
    Translation(coil::Coil, axial_shift::Unitful.Length)

A translation of a coil along the z-axis.
"""
struct Translation <: CoilOperation
    coil::Coil
    axial_shift::Unitful.Length
end

"""
    CurrentInversion(coil::Coil)

A current inversion of a coil.
"""
struct CurrentInversion <: CoilOperation
    coil::Coil
end