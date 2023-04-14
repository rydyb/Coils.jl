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

conductor_coordinates(c::Vector{<:CurrentLoop}) =
    [coordinates for loop in c for coordinates in conductor_coordinates(loop)]
conductor_length(c::Vector{<:CurrentLoop}) = sum(conductor_length(loop) for loop in c)

function mfd(c::Vector{<:CurrentLoop}, ρ, z)
    Bρ, Bz = 0u"T", 0u"T"

    for loop in c
        Bρ += mfd(loop, ρ, z)[1]
        Bz += mfd(loop, ρ, z)[2]
    end

    return Bρ, Bz
end
