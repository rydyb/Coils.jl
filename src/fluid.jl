export Fluid, Channel
export heat_transfer, pressure_drop_tube, pressure_drop_coil

struct Fluid{
    T1<:Unitful.Density,
    T2<:Unitful.Velocity,
    T3<:Unitful.DynamicViscosity,
    T4<:Unitful.HeatCapacity,
    T5<:Unitful.ThermalConductivity,
    T6<:Unitful.Temperature,
}
    density::T1
    velocity::T2
    viscosity::T3
    heat_capacity::T4
    thermal_conductivity::T5
    temperature::T6
end

struct Channel{T<:Unitful.Length}
    hydraulic_diameter::T
    characteristic_length::T
    total_length::T
end

"""
    reynolds_number(f::Flow)

The Reynolds number of a fluid flowing inside a channel.
"""
function reynolds_number(f::Fluid, c::Channel)
    ϱ = f.density
    v = f.velocity
    μ = f.viscosity
    D = c.hydraulic_diameter

    return ϱ * v * D / μ
end

function criticality(f::Fluid, c::Channel)
    Re = reynolds_number(f, c)

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
function nusselt_number_laminar(f::Fluid, c::Channel)
    Re = reynolds_number(f, c)
    Pr = prandtl_number(f)
    λ = c.hydraulic_diameter / c.total_length

    Nu₁ = 4.354
    Nu₂ = 1.953(Re * Pr * λ)^(1 / 3)
    Nu₃ = 0.924Pr^(1 / 3)(Re * λ)^(1 / 2)

    return (Nu₁^3 + 0.6^3 + (Nu₂ - 0.6)^3 + Nu₃^3)^(1 / 3)
end

# VDI Heat Atlas, p. 696, eq. (26)
function nusselt_number_turbulent(f::Fluid, c::Channel)
    Re = reynolds_number(f, c)
    Pr = prandtl_number(f)
    λ = c.hydraulic_diameter / c.total_length
    ξ = (1.8log10(Re) - 1.5)^(-2)

    return ((ξ / 8)Re * Pr) * (1 + λ^(2 / 3)) / (1 + 12.7(ξ / 8)^(1 / 2)(Pr^(2 / 3) - 1))
end

# VDI Heat Atlas, p. 696
function nusselt_number(f::Flow, c::Channel)
    γ = criticality(f, c)

    Nu_laminar = nusselt_number_laminar(f, c)
    Nu_turbulent = nusselt_number_turbulent(f, c)

    return (1 - γ) * Nu_laminar(f) + γ * Nu_turbulent(f)
end

function heat_transfer(f::Fluid, c::Channel)
    k = f.thermal_conductivity
    D = c.hydraulic_diameter
    Nu = nusselt_number(f, c)

    return Nu * (k / D)
end

# VDI Heat Atlas, p. 1057
function pressure_drop_tube(f::Fluid, c::Channel, friction = nothing)
    Re = reynolds_number(f, c)
    L = c.total_length
    d = c.hydraulic_diameter
    ρ = f.density
    u = f.velocity

    if friction === nothing
        ξ = friction
    else
        ξ = 64 / Re
    end

    return ξ * (L / d) * (ρ * u^2 / 2)
end

# VDI Heat Atlas, p. 1062 to 1063
function pressure_drop_coil(
    f::Fluid,
    c::Channel,
    coil_diameter::Unitful.Length,
    coil_pitch::Unitful.Length,
)
    Dw = coil_diameter
    H = coil_pitch
    D = Dw * (1 + (H / (πDw))^2)
    d = c.hydraulic_diameter
    Re = reynolds_number(f, c)

    if (d / D)^(-2) < Re && Re < 2300
        ξ = (64 / Re) * (1 + 0.033(log10(Re * sqrt(d / D))))
    else
        ξ = (0.3164 / Re^(1 / 4)) * (1 + 0.095sqrt(d / D) * Re^(1 / 4))
    end

    return pressure_drop_tube(f, c, ξ)
end