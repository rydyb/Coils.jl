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