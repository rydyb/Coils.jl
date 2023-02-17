"""
    wires(cl::CurrentLoop)

Returns the cylindrical coordinates of a coil's wires.

# Arguments
- `cl::CurrentLoop`: The current loop.

# Returns
- `Vector{Tuple{Float64, Float64}}`: A vector of tuples containing the radial and axial coordinate of each wire.
"""
function wires(cl::CurrentLoop)
    h = cl.height
    R = cl.radius

    return [(R, h)]
end