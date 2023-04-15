export CurrentLoops
export mfd

"""
    CurrentLoops(c::Helical)

Creates an array of `CurrentLoop`s mimicking a `Helical` coil.

# Arguments
- `c::Helical`: The helical coil to mimic.

# Return
- `Vector{CurrentLoop}`: An array of `CurrentLoop`s which mimic the `Helical` coil.
"""
function CurrentLoops(c::Helical)
    coils = Vector{CurrentLoop}(undef, c.radial_turns * c.axial_turns)

    for i = 1:c.radial_turns
        if c.radial_turns == 1
            R = (c.inner_radius + c.outer_radius) / 2
        else
            R = c.inner_radius + (c.outer_radius - c.inner_radius) * (i - 1) / (c.radial_turns - 1)
        end

        for j = 1:c.axial_turns
            if c.axial_turns == 1
                h = c.height
            else
                h = c.height - c.length / 2 + c.length * (j - 1) / (c.axial_turns - 1)
            end

            coils[(i-1)*c.axial_turns+j] = CurrentLoop(current = c.current, radius = R, height = h)
        end
    end

    return coils
end

"""
    CurrentLoops(c::Tuple{<:Helical,<:Helical})

Creates an array of `CurrentLoop`s mimicking a (anti-)Helmholtz configuration of `Helical` coils.

# Arguments
- `c::Tuple{Helical,Helical}`: The two helical coils to mimic.

# Return
- `Vector{CurrentLoop}`: An array of `CurrentLoop`s which mimic the (anti-)Helmholtz configuration of `Helical` coils.
"""
function CurrentLoops(c::Tuple{<:Helical,<:Helical})
    top = CurrentLoops(c[1])
    bottom = CurrentLoops(c[2])

    return vcat(top, bottom)
end

"""
    conductor_coordinates(c::CurrentLoop)

Returns the coordinates of the conductor.

# Arguments
- `c::CurrentLoop`: The `CurrentLoop`.

# Returns
- `Vector{Tuple{Unitful.Length, Unitful.Length}}`: The coordinates of the conductor.
"""
conductor_coordinates(c::Vector{<:CurrentLoop}) =
    [coordinates for loop in c for coordinates in conductor_coordinates(loop)]

"""
    conductor_length(c::Vector{<:CurrentLoop})

Returns the length of the conductor.

# Arguments
- `c::Vector{<:CurrentLoop}`: A list of `CurrentLoop`s.

# Returns
- `Unitful.Length`: The length of the conductor.
"""
conductor_length(c::Vector{<:CurrentLoop}) = sum(conductor_length(loop) for loop in c)

"""
    mfd(c::Vector{<:CurrentLoop}, ρ, z)

Computes the radial and axial magnetic flux density by superimposing `CurrentLoop`s.

# Arguments
- `c::Vector{<:CurrentLoop}`: A list of `CurrentLoop`s.
- `ρ::Unitful.Length`: The radial coordinate.
- `z::Unitful.Length`: The axial coordinate.

# Returns
- `Bρ::Unitful.MagneticFluxDensity`: The radial magnetic flux density.
- `Bz::Unitful.MagneticFluxDensity`: The axial magnetic flux density.
"""
function mfd(c::Vector{<:CurrentLoop}, ρ, z)
    Bρ, Bz = 0u"T", 0u"T"

    for loop in c
        Bρ += mfd(loop, ρ, z)[1]
        Bz += mfd(loop, ρ, z)[2]
    end

    return uconvert.(u"Gauss", [Bρ, Bz])
end
