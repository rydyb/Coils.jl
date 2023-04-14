export Coil
export mfd
export conductor_coordinates, conductor_length

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

"""
    mfd(c::Coil, ρ, z)

Returns the radial and axial magnetic flux density due to a coil.

# Arguments
- `c::Coil`: A specific coil.
- `ρ::Unitful.Length`: The radial distance from the center of the coil.
- `z::Unitful.Length`: The axial distance from the center of the coil.

# Returns
- `Bρ::Unitful.MagneticFluxDensity`: The radial magnetic flux density.
"""
function mfd end