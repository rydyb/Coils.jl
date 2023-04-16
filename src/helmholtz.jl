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

"""
    self_inductance(c::Helmholtz)

Computes an approximate self inductance of each of the coils in (anti-)Helmholtz configuration.

Dispatches the computation to `total_inductance` of the coil configuration.

# Arguments
- `c::Helmholtz`: The (anti-)Helmholtz coil.

# Returns
- `Unitful.Inductance`: The self inductance of each of the coils in (anti-)Helmholtz configuration.
"""
self_inductance(c::Helmholtz) = total_inductance(c.coil)

"""
    mutual_inductance(c::Helmholtz)

Computes an approximate mutual inductance between the coils of the (anti-)Helmholtz pair according to Ref. [1]

- [1]: https://de.wikipedia.org/wiki/Helmholtz-Spule#Induktivit%C3%A4t

# Arguments
- `c::Helmholtz`: The (anti-)Helmholtz coil.

# Returns
- `Unitful.Inductance`: The mutual inductance between the coils of the (anti-)Helmholtz pair.
"""
function mutual_inductance(c::Helmholtz)
    N = Int(c.coil.radial_turns) * Int(c.coil.axial_turns)
    R = (c.coil.inner_radius + c.coil.outer_radius) / 2

    return uconvert(u"μH", 4.941 * N^2 * R * (μ_0 / 4π))
end

"""
    total_inductance(c::Helmholtz)

Computes an approximate total inductance of the (anti-)Helmholtz coil according to Ref. [1]

- [1]: https://de.wikipedia.org/wiki/Helmholtz-Spule#Induktivit%C3%A4t

# Arguments
- `c::Helmholtz`: The (anti-)Helmholtz coil.

# Returns
- `Unitful.Inductance`: The inductance of the (anti-)Helmholtz coil.
"""
function total_inductance(c::Helmholtz)
    L_self = total_inductance(c.coil)
    L_mutual = mutual_inductance(c) * c.polarity

    return 2 * (L_self + L_mutual)
end