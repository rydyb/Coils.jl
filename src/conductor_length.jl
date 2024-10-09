export conductor_length

conductor_length(::AbstractCoil) = throw(ErrorException("not implemented"))

conductor_length(c::RectangularLoop) = 2 * (c.width + c.height)

conductor_length(c::CircularLoop) = typeof(c.diameter)(π) * c.diameter

conductor_length(c::Displace) = conductor_length(c.coil)

conductor_length(c::Reverse) = conductor_length(c.coil)

conductor_length(c::Superposition) = sum(conductor_length(c) for c in c.coils)
