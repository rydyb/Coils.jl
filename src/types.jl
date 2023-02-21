export Coil, CurrentLoop, AxialOffset, ReverseCurrent, Superposition

"""
    Coil

An abstract type for coils.
"""
abstract type Coil end

"""
    CurrentLoop(current, radius)

A current loop with a given current and radius centered at the origin.
"""
struct CurrentLoop{T} <: Coil
    current::T
    radius::T
end

"""
    AxialOffset(coil, offset)

A coil shifted axialy with respect to the origin.
"""
struct AxialOffset{T} <: Coil
    coil::Coil
    offset::T
end

"""
    ReverseCurrent(coil)

A coil with the current reversed.
"""
struct ReverseCurrent <: Coil
    coil::Coil
end

"""
    Superposition(coils::Vector{::Coil})

A superposition of coils.
"""
struct Superposition <: Coil
    coils::Vector{Coil}
end

export Solenoid, Helmholtz, AntiHelmholtz

"""
    Solenoid(current, inner_radius, axial_turns, axial_spacing, radial_turns, radial_spacing)

Creates a superposition representing a solenoid with a given current, inner radius, axial turns, axial spacing, radial turns, and radial spacing.

# Arguments
- `current`: The current in the solenoid in Amps.
- `inner_radius`: The inner radius of the solenoid in meters.
- `axial_turns::Int`: The number of axial turns in the solenoid.
- `axial_spacing`: The axial spacing between turns in meters.
- `radial_turns::Int`: The number of radial turns in the solenoid.
- `radial_spacing`: The radial spacing between turns in meters.

# Returns
- `::Superposition`: A superposition representing the solenoid.
"""
function Solenoid(current, inner_radius, axial_turns, axial_spacing, radial_turns, radial_spacing)
    coils = Vector{Coil}(undef, axial_turns * radial_turns)

    height = axial_turns * axial_spacing

    for i in 1:axial_turns
        for j in 1:radial_turns
            z = (i - 1) * axial_spacing - height / 4
            ρ = inner_radius + (j - 1) * radial_spacing

            coils[(i-1)*radial_turns+j] = AxialOffset(CurrentLoop(current, ρ), z)
        end
    end

    return Superposition(coils)
end

"""
    Helmholtz(solenoid::Coil, separation)

Creates a superposition representing a Helmholtz coil with a given solenoid and separation.

# Arguments
- `solenoid::Coil`: The solenoid.
- `separation`: The separation between the solenoids in meters.

# Returns
- `::Superposition`: A superposition representing the Helmholtz coil.
"""
function Helmholtz(solenoid::Coil, separation)
    coils = Vector{Coil}(undef, 2)

    coils[1] = AxialOffset(solenoid, +separation / 2)
    coils[2] = AxialOffset(solenoid, -separation / 2)

    return Superposition(coils)
end

"""
    AntiHelmholtz(solenoid::Coil, separation)

Creates a superposition representing an anti-Helmholtz coil with a given solenoid and separation.

# Arguments
- `solenoid::Coil`: The solenoid.
- `separation::Float64`: The separation between the solenoids in meters.

# Returns
- `::Superposition`: A superposition representing the anti-Helmholtz coil.
"""
function AntiHelmholtz(solenoid::Coil, separation)
    coils = Vector{Coil}(undef, 2)

    coils[1] = AxialOffset(solenoid, +separation / 2)
    coils[2] = ReverseCAxialOffset(solenoid, -separation / 2)

    return Superposition(coils)
end