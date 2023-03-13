export Fluid, Water, Tube, CoiledTube
export reynolds_number,
    prandtl_number, nusselt_number, nusselt_number_laminar, nusselt_number_turbulent, criticality
export heat_transfer, pressure_drop_tube, pressure_drop_coil

"""
    Fluid

A fluid with a density, velocity, viscosity, heat capacity, thermal conductivity, and temperature.
"""
struct Fluid{
    T1<:Unitful.Density,
    T2<:Unitful.Velocity,
    T3<:Unitful.DynamicViscosity,
    T4<:SpecificHeatCapacity,
    T5<:ThermalConductivity,
    T6<:Unitful.Temperature,
}
    density::T1
    velocity::T2
    viscosity::T3
    heat_capacity::T4
    thermal_conductivity::T5
    temperature::T6
end

Fluid(;
    density::Unitful.Density,
    velocity::Unitful.Velocity,
    viscosity::Unitful.DynamicViscosity,
    heat_capacity::SpecificHeatCapacity,
    thermal_conductivity::ThermalConductivity,
    temperature::Unitful.Temperature,
) = Fluid(density, velocity, viscosity, heat_capacity, thermal_conductivity, temperature)

"""
    Water

Returns a Fluid with the properties of water close to room temperature.
"""
Water(; velocity::Unitful.Velocity, temperature::Unitful.Temperature) = Fluid(
    density = 997u"kg/m^3",
    velocity = velocity,
    viscosity = 1u"mPa*s",
    heat_capacity = 4186u"J/(kg*K)",
    thermal_conductivity = 0.591u"W/(m*K)",
    temperature = temperature,
)

"""
    Tube

A tube or channel with a diameter and length through which a fluid flows.
"""
struct Tube{T1<:Unitful.Length,T2<:Unitful.Length}
    diameter::T1
    length::T2
end

Tube(; diameter::Unitful.Length, length::Unitful.Length) = Tube(diameter, length)

"""
    CoiledTube

A tube or channel in the shape of a coil with a diameter and pitch.
"""
struct CoiledTube{T<:Tube,T1<:Unitful.Length,T2<:Unitful.Length}
    tube::T
    diameter::T1
    pitch::T2
end

CoiledTube(t::Tube; diameter::Unitful.Length, pitch::Unitful.Length) =
    CoiledTube(t, diameter, pitch)

"""
    reynolds_number(f::Flow)

The Reynolds number of a fluid flowing inside a Tube.
"""
function reynolds_number(f::Fluid, t::Tube)
    ϱ = f.density
    v = f.velocity
    μ = f.viscosity
    D = t.diameter

    return upreferred(ϱ * v * D / μ)
end

"""
    criticality(f::Fluid, t::Tube)

Quantifies the critical region of a fluid flowing inside a Tube.

A value of 0 indicates a laminar flow, a value of 1 indicates a turbulent flow.
"""
function criticality(f::Fluid, t::Tube)
    Re = reynolds_number(f, t)

    return clamp((Re - 2300) / (1e4 - 2300), 0.0, 1.0)
end

"""
    prandtl_number(f::Fluid)

The Prandtl number of a fluid.
"""
function prandtl_number(f::Fluid)
    c = f.heat_capacity
    μ = f.viscosity
    k = f.thermal_conductivity

    return c * μ / k
end

# VDI Heat Atlas, p. 652, eq. (25)
function nusselt_number_laminar(f::Fluid, t::Tube)
    Re = reynolds_number(f, t)
    Pr = prandtl_number(f)
    λ = t.diameter / t.length

    Nu₁ = 4.354
    Nu₂ = 1.953(Re * Pr * λ)^(1 / 3)
    Nu₃ = (0.924Pr)^(1 / 3) * (Re * λ)^(1 / 2)

    return (Nu₁^3 + 0.6^3 + (Nu₂ - 0.6)^3 + Nu₃^3)^(1 / 3)
end

# VDI Heat Atlas, p. 696, eq. (26)
function nusselt_number_turbulent(f::Fluid, t::Tube)
    Re = reynolds_number(f, t)
    Pr = prandtl_number(f)
    λ = t.diameter / t.length
    ξ = (1.8log10(Re) - 1.5)^(-2)

    return ((ξ / 8)Re * Pr) * (1 + λ^(2 / 3)) / (1 + 12.7(ξ / 8)^(1 / 2) * (Pr^(2 / 3) - 1))
end

"""
    nusselt_number(f::Fluid, t::Tube)

The Nusselt number of a fluid flowing inside a tube where we interpolate over the critical region.
"""
# VDI Heat Atlas, p. 696
function nusselt_number(f::Fluid, t::Tube)
    γ = criticality(f, t)

    Nu_laminar = nusselt_number_laminar(f, t)
    Nu_turbulent = nusselt_number_turbulent(f, t)

    return (1 - γ) * Nu_laminar + γ * Nu_turbulent
end

"""
    heat_transfer(f::Fluid, t::Tube)

The heat transfer coefficient of a fluid flowing inside a tube.
"""
function heat_transfer(f::Fluid, t::Tube)
    k = f.thermal_conductivity
    D = t.diameter
    Nu = nusselt_number(f, t)

    return Nu * (k / D)
end

"""
    pressure_drop_tube(f::Fluid, t::Tube; friction = nothing)

The pressure drop of a fluid flowing inside a tube due to drag of the fluid along the tube's boundary.
"""
# VDI Heat Atlas, p. 1057
function pressure_drop_tube(f::Fluid, t::Tube; friction = nothing)
    Re = reynolds_number(f, t)
    L = t.length
    d = t.diameter
    ρ = f.density
    u = f.velocity

    if friction === nothing
        ξ = 64 / Re
    else
        ξ = friction
    end

    return uconvert(u"bar", ξ * (L / d) * (ρ * u^2 / 2))
end

"""
    pressure_drop_coil(f::Fluid, ct::CoiledTube)

The pressure drop of a fluid flowing inside a coiled tube.
In addition to friction, a fluid experiences centrifugal forces due to the coiling of the tube.
"""
# VDI Heat Atlas, p. 1062 to 1063
function pressure_drop_coil(f::Fluid, ct::CoiledTube;)
    Dw = ct.diameter
    H = ct.pitch
    D = Dw * (1 + (H / (π * Dw))^2)
    d = ct.tube.diameter
    Re = reynolds_number(f, ct.tube)

    if (d / D)^(-2) < Re && Re < 2300
        ξ = (64 / Re) * (1 + 0.033(log10(Re * sqrt(d / D))))
    else
        ξ = (0.3164 / Re^(1 / 4)) * (1 + 0.095sqrt(d / D) * Re^(1 / 4))
    end

    return pressure_drop_tube(f, ct.tube, friction = ξ)
end