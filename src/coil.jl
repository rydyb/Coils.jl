export Coil
export mfd, mfdz
export conductor_coordinates, conductor_length
export self_inductance, mutual_inductance, total_inductance

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

Computes the radial and axial magnetic flux density due to a current flowing through a coil.

# Arguments
- `c::Coil`: A specific coil.
- `ρ::Unitful.Length`: The radial distance from the center of the coil.
- `z::Unitful.Length`: The axial distance from the center of the coil.

# Returns
- `Bρ::Unitful.MagneticFluxDensity`: The radial magnetic flux density.
"""
function mfd end

"""
    mfdz(c::Coil[, z])

Computes the axial magnetic flux density along the longitudinal axis due to a current flowing through a coil.

Usually, you want to use `mfd` to compute the magnetic flux density at a given point.
However, for some coil configurations simplified formulas for the axial magnetic flux density exist, which can be compared with `mfd` as a safety check.

# Arguments
- `c::Coil`: The coil.
- `z::Unitful.Length`: The axial coordinate by default equal to the height of the coil `c`.

# Returns
- `Bz::Unitful.MagneticFluxDensity`: The axial magnetic flux density.
"""
function mfdz end