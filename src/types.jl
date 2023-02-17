"""
    Coil

An abstract type for coils.
"""
abstract type Coil end

"""
    CurrentLoop(current, radius)

A current loop with a given current and radius.

# Arguments
- `current::Float64`: The current in the loop in Amps.
- `radius::Float64`: The radius of the loop in meters.
"""
struct CurrentLoop <: Coil
    current::Float64
    radius::Float64
end

"""
    Superposition(coils::Vector{<:Coil})

A superposition of coils.
"""
abstract type Superposition <: Coil end

"""
    Solenoid(current, inner_radius, axial_turns, axial_spacing, radial_turns, radial_spacing)

A solenoid with a given current, inner radius, axial turns, axial spacing, radial turns, and radial spacing.

# Arguments
- `current::Float64`: The current in the solenoid in Amps.
- `inner_radius::Float64`: The inner radius of the solenoid in meters.
- `axial_turns::Int`: The number of axial turns in the solenoid.
- `axial_spacing::Float64`: The axial spacing between turns in meters.
- `radial_turns::Int`: The number of radial turns in the solenoid.
- `radial_spacing::Float64`: The radial spacing between turns in meters.
"""
struct Solenoid <: Superposition
    current::Float64
    inner_radius::Float64
    axial_turns::Int
    axial_spacing::Float64
    radial_turns::Int
    radial_spacing::Float64
end

end