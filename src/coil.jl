"""
    Coil

An abstract type for a magnetic coil.
"""
abstract type Coil end

"""
    conductor_coordinates(c::Coil)

Returns the coordinates of the conductor in cylindrical coordinates.

# Arguments
- `c::Coil`: A specific coil.

# Returns
- `coordinates::Vector{Vector{Unitful.Length}}`: The coordinates of the conductor.
"""
function conductor_coordinates end


"""
    conductor_length(c::Coil)

Returns the total length of the conductor.

# Arguments
- `c::Coil`: A specific coil.

# Returns
- `length::Unitful.Length`: The length of the conductor.
"""
function conductor_length end