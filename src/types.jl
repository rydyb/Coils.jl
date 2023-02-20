"""
    Coil

An abstract type for coils.
"""
abstract type Coil end

"""
    CurrentLoop(current, radius)

A current loop with a given current and radius centered at the origin.

# Arguments
- `current::Float64`: The current in the loop in Amps.
- `radius::Float64`: The radius of the loop in meters.
"""
struct CurrentLoop <: Coil
    current::Float64
    radius::Float64
end

"""
    AxialOffset(coil, offset)

A coil shifted axialy with respect to the origin.
"""
struct AxialOffset <: Coil
    coil::Coil
    offset::Float64
end

"""
    Superposition(coils::Vector{::Coil})

A superposition of coils.
"""
struct Superposition <: Coil
    coils::Vector{Coil}

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
    function Solenoid(current, inner_radius, axial_turns, axial_spacing, radial_turns, radial_spacing)
        coils = Vector{Coil}(undef, axial_turns * radial_turns)

        for i in 1:axial_turns
            for j in 1:radial_turns
                z = (i - 1) * axial_spacing
                ρ = inner_radius + (j - 1) * radial_spacing

                coils[(i-1)*radial_turns+j] = AxialOffset(CurrentLoop(current, ρ), z)
            end
        end

        return new(coils)
    end
end
