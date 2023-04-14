"""
    LoopArray(c::Helical)

Creates an array of `Loop`s mimicking a `Helical` coil.

# Arguments
- `c::Helical`: The helical coil to mimic.

# Return
- `Vector{Loop}`: An array of `Loop`s which mimic the `Helical` coil.
"""
function LoopArray(c::Helical)
    coils = Vector{Loop}(undef, c.radial_turns * c.axial_turns)

    I = c.current
    H = c.height
    L = c.length
    W = c.outer_radius - c.inner_radius
    Rin = c.inner_radius
    Rout = c.outer_radius
    Reff = (Rin + Rout) / 2

    for i = 1:Nρ
        if Nρ == 1
            R = Reff
        else
            R = Rin + (W / 1) * (i - 1) / (Nρ - 1)
        end

        for j = 1:Nz
            if Nz == 1
                h = H
            else
                h = H - L / 2 + L * (j - 1) / (Nz - 1)
            end

            coils[(i-1)*Nz+j] = Loop(current = I, radius = R, height = h)
        end
    end

    return coils
end

conductor_coordinates(c::Vector{Loop}) = [ρz for loop in c for ρz in conductor_coordinates(loop)]
conductor_length(c::Vector{Loop}) = sum(conductor_length(loop) for loop in c)

"""
    mfd(c::Vector{Loop}, ρ, z)

Returns the magnetic flux density due to the loop at the given point.

# Arguments
- `c::Vector{Loop}`: The loop to get the magnetic flux density of.
- `ρ::Unitful.Length`: The radial distance from the center of the loop.
- `z::Unitful.Length`: The axial distance from the center of the loop.

# Return
- `Vector{Unitful.MagneticFluxDensity}`: The radial and axial components of the magnetic flux density.
"""
mfd(c::Vector{Loop}, ρ, z) = sum(mfd(loop, ρ, z) for loop in c)
