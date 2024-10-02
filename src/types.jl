using DynamicQuantities

export AbstractCoil
export CircularLoop, RectangularLoop
export Displace, Reverse, Superposition

abstract type AbstractCoil end

struct CircularLoop{T<:AbstractQuantity} <: AbstractCoil
    current::T
    radius::T

    function CircularLoop(; current::T, radius::T) where {T}
        @assert dimension(current) === dimension(u"A") "current must have units of current"
        @assert dimension(radius) === dimension(u"m") "radius must have units of length"
        @assert ustrip(radius) > 0 "radius must be positive"
        new{T}(current, radius)
    end
end

struct RectangularLoop{T<:AbstractQuantity} <: AbstractCoil
    current::T
    width::T
    height::T

    function RectangularLoop(; current::T, width::T, height::T) where {T}
        @assert dimension(current) === dimension(u"A") "current must have units of current"
        @assert dimension(width) === dimension(u"m") "width must have units of length"
        @assert dimension(height) === dimension(u"m") "height must have units of length"
        @assert ustrip(width) > 0 && ustrip(height) > 0 "width and height must be positive"
        new{T}(current, width, height)
    end
end

struct Displace{C<:AbstractCoil,T<:AbstractQuantity} <: AbstractCoil
    coil::C
    x::T
    y::T
    z::T

    function Displace(coil::C; x::T = zero(u"m"), y::T = zero(u"m"), z::T = zero(u"m")) where {C,T}
        @assert dimension(x) === dimension(u"m") "x must have units of length"
        @assert dimension(y) === dimension(u"m") "y must have units of length"
        @assert dimension(z) === dimension(u"m") "z must have units of length"
        new{C,T}(coil, x, y, z)
    end
end

struct Reverse{C<:AbstractCoil} <: AbstractCoil
    coil::C

    function Reverse(coil::C) where {C}
        new{C}(coil)
    end
end

struct Superposition{C<:AbstractCoil} <: AbstractCoil
    coils::Vector{C}

    function Superposition(coils::Vector{C}) where {C}
        new{C}(coils)
    end
end
