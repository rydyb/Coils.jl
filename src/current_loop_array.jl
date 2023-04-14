export CurrentLoopArray
export mfd

"""
    CurrentLoopArray(c::Helical)

Creates an array of `CurrentLoop`s mimicking a `Helical` coil.

# Arguments
- `c::Helical`: The helical coil to mimic.

# Return
- `Vector{CurrentLoop}`: An array of `CurrentLoop`s which mimic the `Helical` coil.
"""
function CurrentLoopArray(c::Helical)
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

conductor_coordinates(c::Vector{CurrentLoop}) =
    [ρz for CurrentLoop in c for ρz in conductor_coordinates(CurrentLoop)]
conductor_length(c::Vector{CurrentLoop}) = sum(conductor_length(CurrentLoop) for CurrentLoop in c)

"""
    mfd(c::Vector{CurrentLoop}, ρ, z)

Returns the magnetic flux density due to the CurrentLoop at the given point.

# Arguments
- `c::Vector{CurrentLoop}`: The CurrentLoop to get the magnetic flux density of.
- `ρ::Unitful.Length`: The radial distance from the center of the CurrentLoop.
- `z::Unitful.Length`: The axial distance from the center of the CurrentLoop.

# Return
- `Vector{Unitful.MagneticFluxDensity}`: The radial and axial components of the magnetic flux density.
"""
mfd(c::Vector{CurrentLoop}, ρ, z) = sum(mfd(CurrentLoop, ρ, z) for CurrentLoop in c)
