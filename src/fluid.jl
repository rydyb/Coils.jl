export Fluid, Water, Tube
export reynolds_number,
    prandtl_number, nusselt_number, nusselt_number_laminar, nusselt_number_turbulent, criticality
export heat_transfer, pressure_drop_tube, pressure_drop_coil

@derived_dimension SpecificHeatCapacity dimension(u"J/(kg*K)")
@derived_dimension ThermalConductivity dimension(u"W/(m*K)")

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

Water(; velocity::Unitful.Velocity, temperature::Unitful.Temperature) = Fluid(
    density = 997u"kg/m^3",
    velocity = velocity,
    viscosity = 1u"mPa*s",
    heat_capacity = 4186u"J/(kg*K)",
    thermal_conductivity = 0.591u"W/(m*K)",
    temperature = temperature,
)

struct Tube{T1<:Unitful.Length,T2<:Unitful.Length}
    hydraulic_diameter::T1
    total_length::T2
end

Tube(; hydraulic_diameter::Unitful.Length, total_length::Unitful.Length) =
    Tube(hydraulic_diameter, total_length)

"""
    reynolds_number(f::Flow)

The Reynolds number of a fluid flowing inside a Tube.
"""
function reynolds_number(f::Fluid, t::Tube)
    ϱ = f.density
    v = f.velocity
    μ = f.viscosity
    D = t.hydraulic_diameter

    return upreferred(ϱ * v * D / μ)
end

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
    λ = t.hydraulic_diameter / t.total_length

    Nu₁ = 4.354
    Nu₂ = 1.953(Re * Pr * λ)^(1 / 3)
    Nu₃ = (0.924Pr)^(1 / 3) * (Re * λ)^(1 / 2)

    return (Nu₁^3 + 0.6^3 + (Nu₂ - 0.6)^3 + Nu₃^3)^(1 / 3)
end

# VDI Heat Atlas, p. 696, eq. (26)
function nusselt_number_turbulent(f::Fluid, t::Tube)
    Re = reynolds_number(f, t)
    Pr = prandtl_number(f)
    λ = t.hydraulic_diameter / t.total_length
    ξ = (1.8log10(Re) - 1.5)^(-2)

    return ((ξ / 8)Re * Pr) * (1 + λ^(2 / 3)) / (1 + 12.7(ξ / 8)^(1 / 2) * (Pr^(2 / 3) - 1))
end

# VDI Heat Atlas, p. 696
function nusselt_number(f::Fluid, t::Tube)
    γ = criticality(f, t)

    Nu_laminar = nusselt_number_laminar(f, t)
    Nu_turbulent = nusselt_number_turbulent(f, t)

    return (1 - γ) * Nu_laminar + γ * Nu_turbulent
end

function heat_transfer(f::Fluid, t::Tube)
    k = f.thermal_conductivity
    D = t.hydraulic_diameter
    Nu = nusselt_number(f, t)

    return Nu * (k / D)
end

# VDI Heat Atlas, p. 1057
function pressure_drop_tube(f::Fluid, t::Tube; friction = nothing)
    Re = reynolds_number(f, t)
    L = t.total_length
    d = t.hydraulic_diameter
    ρ = f.density
    u = f.velocity

    if friction === nothing
        ξ = 64 / Re
    else
        ξ = friction
    end

    return uconvert(u"bar", ξ * (L / d) * (ρ * u^2 / 2))
end

# VDI Heat Atlas, p. 1062 to 1063
function pressure_drop_coil(
    f::Fluid,
    t::Tube;
    coil_diameter::Unitful.Length,
    coil_pitch::Unitful.Length,
)
    Dw = coil_diameter
    H = coil_pitch
    D = Dw * (1 + (H / (π * Dw))^2)
    d = t.hydraulic_diameter
    Re = reynolds_number(f, t)

    if (d / D)^(-2) < Re && Re < 2300
        ξ = (64 / Re) * (1 + 0.033(log10(Re * sqrt(d / D))))
    else
        ξ = (0.3164 / Re^(1 / 4)) * (1 + 0.095sqrt(d / D) * Re^(1 / 4))
    end

    return pressure_drop_tube(f, t, friction = ξ)
end