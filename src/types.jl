using DynamicQuantities

export AbstractCoil
export CircularLoop, RectangularLoop
export Displace, Reverse, Superposition
export CircularCoil, Helmholtz, AntiHelmholtz

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

Helmholtz(coil::AbstractCoil; distance::AbstractQuantity) =
    Superposition([Displace(coil, z = distance / 2), Displace(coil, z = -distance / 2)])

AntiHelmholtz(coil::AbstractCoil; distance::AbstractQuantity) =
    Superposition([Displace(coil, z = distance / 2), Reverse(Displace(coil, z = -distance / 2))])

function CircularCoil(; current, radial_turns, axial_turns, inner_radius, outer_radius, height)
	# radial and axial offset
	ρ₀ = inner_radius
	z₀ = -height / 2

	# radial and axial spacing
	Δρ = (outer_radius - inner_radius) / (radial_turns-1)
	Δz = height / (axial_turns - 1)

	# superimpose the circular current loops
	loops = Vector{AbstractCoil}()
	for i in 1:radial_turns
		loop = CircularLoop(current=current, radius=ρ₀ + Δρ * (i - 1))

		for j in 1:axial_turns
			dloop = Displace(loop; z = z₀ + Δz * (j - 1))

			push!(loops, dloop)
		end
	end

	return Superposition(loops)
end
