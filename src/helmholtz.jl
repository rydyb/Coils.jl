export Helmholtz, AntiHelmholtz
export inductance

"""
    Helmholtz(; coil::Helical, separation::Unitful.Length = (coil.outer_radius + coil.inner_radius) / 2)
    AntiHelmholtz(; coil::Helical, separation::Unitful.Length = √3 * (coil.outer_radius + coil.inner_radius) / 2

A(n) (anti-)Helmholtz coil configuration of `Helical` coils.

# Keywords
- `coil::Helical`: The `Helical` coil configuration.
- `separation::Unitful.Length`: The separation between the coils by default uses the ideal separation.
"""
struct Helmholtz{T1<:Helical,T2<:Unitful.Length,T3<:Int}
    coil::T1
    separation::T2
    polarity::T3
end

Helmholtz(;
    coil::Helical,
    separation::Unitful.Length = (coil.outer_radius + coil.inner_radius) / 2,
) = Helmholtz(coil, separation, 1)

AntiHelmholtz(;
    coil::Helical,
    separation::Unitful.Length = √3 * (coil.outer_radius + coil.inner_radius) / 2,
) = Helmholtz(coil, separation, -1)

"""
    inductance(c::Helmholtz)

Returns the approximate inductance of the (anti-)Helmholtz coil according to Ref. [1]

- [1]: https://de.wikipedia.org/wiki/Helmholtz-Spule#Induktivit%C3%A4t

# Arguments
- `c::Helmholtz`: The (anti-)Helmholtz coil.

# Returns
- `Unitful.Inductance`: The inductance of the (anti-)Helmholtz coil.
"""
function inductance(c::Helmholtz)
    N = Int(c.coil.radial_turns) * Int(c.coil.axial_turns)
    R = (c.coil.inner_radius + c.coil.outer_radius) / 2
    L = c.coil.length

    C = 2μ_0 * R * N^2
    L1 = π * R / (L + 2R / 2.2)
    L2 = 4.941 / 4π

    return C * (L1 + L2 * c.polarity)
end

"""
    mfdz(c::Helmholtz)

Computes the magnetic flux density at the center of an infinite-length (anti-)Helmholtz coil according to [1].

- [1]: https://en.wikipedia.org/wiki/Helmholtz_coil

We use the formula of an infinite-length solenoid where we use the product of radial and axial turns as the number of turns.

# Arguments
- `c::Helmholtz`: The (anti-)Helmholtz coil.

# Returns
- `Vector{Unitful.MagneticFluxDensity}`: The radial and axial magnetic flux density components.
"""
function mfdz(c::Helmholtz)
    Bρ = 0.0u"Gauss"

    # the mfd components are zero at the center of an anti-helmholtz coil pair
    if (c.polarity == -1)
        return [Bρ, Bρ]
    end

    I = c.coil.current
    N = c.coil.radial_turns * c.coil.axial_turns
    R = (c.coil.inner_radius + c.coil.outer_radius) / 2

    Bz = (4 / 5)^(3 / 2) * μ_0 * I * N / R

    return uconvert.(u"Gauss", [Bρ, Bz])
end