export conductor_length

function conductor_length(r::RectangularLoop)
    return 2 * (r.width + r.height)
end

function conductor_length(c::CircularLoop)
    return 2π * c.radius
end
