using DynamicQuantities

export AbstractCoil
export CircularLoop, RectangularLoop
export Displace, Reverse, Superposition
export CircularCoil, RectangularCoil, Helmholtz, AntiHelmholtz

abstract type AbstractCoil end

struct CircularLoop{T<:AbstractQuantity} <: AbstractCoil
    current::T
    diameter::T

    function CircularLoop(; current::T, diameter::T) where {T}
        @assert dimension(current) === dimension(u"A") "current must have units of current"
        @assert dimension(diameter) === dimension(u"m") "radius must have units of length"
        @assert ustrip(diameter) > 0 "radius must be positive"
        new{T}(current, diameter)
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

Helmholtz(coil::AbstractCoil; distance::AbstractQuantity) =
    Superposition([Displace(coil, z = distance / 2), Displace(coil, z = -distance / 2)])

AntiHelmholtz(coil::AbstractCoil; distance::AbstractQuantity) =
    Superposition([Displace(coil, z = distance / 2), Reverse(Displace(coil, z = -distance / 2))])

function CircularCoil(;
    current,
    radial_turns,
    axial_turns,
    inner_diameter,
    outer_diameter,
    thickness,
)
    # offsets
    d₀ = inner_diameter
    z₀ = -thickness / 2

    # spacings
    Δd = (outer_diameter - inner_diameter) / (radial_turns - 1)
    Δz = thickness / (axial_turns - 1)

    # superimpose the circular current loops
    loops = Vector{AbstractCoil}()
    for i = 1:radial_turns
        loop = CircularLoop(current = current, diameter = d₀ + Δd * (i - 1))

        for j = 1:axial_turns
            dloop = Displace(loop; z = z₀ + Δz * (j - 1))

            push!(loops, dloop)
        end
    end

    return Superposition(loops)
end

function RectangularCoil(;
    current,
    radial_turns,
    axial_turns,
    inner_width,
    outer_width,
    inner_height,
    outer_height,
    thickness,
)
    # offsets
    x₀ = inner_width
    y₀ = inner_height
    z₀ = -thickness / 2

    # spacings
    Δx = (outer_width - inner_width) / (radial_turns - 1)
    Δy = (outer_height - inner_height) / (radial_turns - 1)
    Δz = thickness / (axial_turns - 1)

    # superimpose the rectangular current loops
    loops = Vector{AbstractCoil}()
    for i = 1:radial_turns
        loop = RectangularLoop(
            current = current,
            width = x₀ + Δx * (i - 1),
            height = y₀ + Δy * (i - 1),
        )

        for j = 1:axial_turns
            dloop = Displace(loop; z = z₀ + Δz * (j - 1))

            push!(loops, dloop)
        end
    end

    return Superposition(loops)
end
