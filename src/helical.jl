export Helical, Pancake, Solenoid

"""
    Helical(; current, inner_radius, outer_radius, length, height, turns)

A helical coil with turns in radial and axial directions.

# Fields
- `current::Unitful.Current`: The current in the coil.
- `inner_radius::Unitful.Length`: The inner radius of the coil.
- `outer_radius::Unitful.Length`: The outer radius of the coil.
- `length::Unitful.Length`: The (axial) length of the coil.
- `height::Unitful.Length`: The height or axial offset of the coil.
- `radial_turns::Unsigned`: The number of turns in the radial direction.
- `axial_turns::Unsigned`: The number of turns in the axial direction.
"""
struct Helical{
    T1<:Unitful.Current,
    T2<:Unitful.Length,
    T3<:Unitful.Length,
    T4<:Unitful.Length,
    T5<:Unitful.Length,
    T6<:Unsigned,
} <: Coil
    current::T1
    inner_radius::T2
    outer_radius::T3
    length::T4
    height::T5
    radial_turns::T6
    axial_turns::T6
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
    Pancake(; current, inner_radius, outer_radius, turns, height)

A pancake coil which has only turns in the radial direction.

# Keywords
- `current::Unitful.Current`: The current in the coil.
- `inner_radius::Unitful.Length`: The inner radius of the coil.
- `outer_radius::Unitful.Length`: The outer radius of the coil.
- `turns::Unsigned`: The number of turns in the radial direction.
- `height::Unitful.Length`: The height or axial offset of the coil.

# Return
- `Helical`: A helical coil with only radial turns.
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
    Solenoid(; current, radius, length, turns, height)

A solenoid coil which has only turns in the axial direction.

# Keywords
- `current::Unitful.Current`: The current in the coil.
- `radius::Unitful.Length`: The radius of the coil.
- `length::Unitful.Length`: The (axial) length of the coil.
- `turns::Unsigned`: The number of turns in the axial direction.
- `height::Unitful.Length`: The height or axial offset of the coil.

# Return
- `Helical`: A helical coil with only axial turns.
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

