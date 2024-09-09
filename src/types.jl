using DynamicQuantities: ustrip

export Coil
export conductor_length
export magnetic_flux_density
export CircularLoop
export RectangularLoop

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

struct Translation{T<:Coil,V<:AbstractVector} <: Coil
    coil::T
    vector::V

    function Translation(coil::T, vector::V) where {T,V}
        @assert length(vector) == 3 "vector must have three components"
        new{T,V}(coil, vector)
    end
end
