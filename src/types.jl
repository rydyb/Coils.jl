using DynamicQuantities

export Coil
export conductor_length
export magnetic_flux_density
export CircularLoop
export RectangularLoop
export Translation

struct NotImplementedError <: Exception end

abstract type Coil end

conductor_length(::Coil) = throw(NotImplementedError())

magnetic_flux_density(::Coil, args...) = throw(NotImplementedError())

struct CircularLoop{T1<:Number,T2<:Number} <: Coil
    current::T1
    radius::T2

    function CircularLoop(; current::T1, radius::T2) where {T1,T2}
        @assert ustrip(radius) > 0 "radius must be positive"
        new{T1,T2}(current, radius)
    end
end

struct RectangularLoop{T1<:Number,T2<:Number,T3<:Number} <: Coil
    current::T1
    width::T2
    height::T3

    function RectangularLoop(; current::T1, width::T2, height::T3) where {T1,T2,T3}
        @assert ustrip(width) > 0 && ustrip(height) > 0 "width and height must be positive"
        new{T1,T2,T3}(current, width, height)
    end
end

struct Translation{C<:Coil, T<:Number} <: Coil
    coil::C
    vector::Vector{T}

    function Translation(coil::C, x::T, y::T, z::T) where {C<:Coil, T<:Number}
        new{C,T}(coil, [x, y, z])
    end

    function Translation(coil::C, vector::Vector{T}) where {C<:Coil,T<:Number}
        @assert length(vector) == 3 "Translation vector must have 3 components"
        new{C,T}(coil, vector)
    end
end
