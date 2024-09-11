export conductor_length

conductor_length(::Coil) = throw(ErrorException("not implemented"))

conductor_length(c::RectangularLoop) = 2 * (c.width + c.height)

conductor_length(c::CircularLoop) = typeof(c.radius)(2π) * c.radius

conductor_length(c::Displace) = conductor_length(c.coil)

conductor_length(c::Reverse) = conductor_length(c.coil)

conductor_length(v::Vector{<:Coil}) = sum(conductor_length(c) for c in v)
