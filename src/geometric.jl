"""
    wires(cl::CurrentLoop)

Returns the cylindrical coordinates of a current loop centered at the origin.

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

"""
    wires(ao::AxialOffset)

Returns the cylindrical coordinates of a coil's wires shifted axialy with respect to the origin.

# Arguments
- `ao::AxialOffset`: The coil shifted axialy with respect to the origin.

# Returns
- `Vector{Tuple{Float64, Float64}}`: A vector of tuples containing the radial and axial coordinate of each wire.
"""
function wires(ao::AxialOffset)
    cl = ao.coil
    z₀ = ao.offset

    return [(ρ, z + z₀) for (ρ, z) in wires(cl)]
end

"""
    wires(sp::Superposition)

Returns the cylindrical coordinates of a superposition of coils.

# Arguments
- `sp::Superposition`: The coil comprising a superposition of coils.

# Returns
- `Vector{Tuple{Float64, Float64}}`: A vector of tuples containing the radial and axial coordinate of each wire.
"""
function wires(sp::Superposition)
    return [(ρ, z) for c in sp.coils for (ρ, z) in wires(c)]
end