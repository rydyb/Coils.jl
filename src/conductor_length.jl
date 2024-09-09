export conductor_length

function conductor_length(r::RectangularLoop)
    return 2 * (r.width + r.height)
end

function conductor_length(c::CircularLoop)
    return typeof(c.radius)(2π) * c.radius
end

function conductor_length(t::Translation)
    return conductor_length(t.coil)
end

function conductor_length(v::Vector{<:Coil})
    return sum(conductor_length(c) for c in v)
end
