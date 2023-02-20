"""
    Fluid(density::Float64, velocity::Float64, viscosity::Float64)

A fluid.
"""
struct Fluid
  density::Float64
  velocity::Float64
  viscosity::Float64
  heat_capacity::Float64
  thermal_conductivity::Float64
end

"""
  Flow(fluid::Fluid, hydraulic_diameter::Float64)

A flow.
"""
struct Flow
  fluid::Fluid
  hydraulic_diameter::Float64
  characteristic_length::Float64
end

"""
    reynolds_number(f::Flow)

The Reynolds number of a flow.

# Arguments
- `f::Flow`: The flow to calculate the Reynolds number for.

# Returns
- `Float64`: The Reynolds number of the flow.
"""
function reynolds_number(f::Flow)
  ϱ = f.fluid.density
  v = f.fluid.velocity
  μ = f.fluid.viscosity
  D = f.hydraulic_diameter

  return ϱ * v * D / μ
end

function criticality(f::Flow)
  Re = reynolds_number(f)

  return clamp((Re - 2300) / (1e4 - 2300), 0.0, 1.0)
end

"""
    prandtl_number(f::Fluid)

The Prandtl number of a fluid.
"""
function prandtl_number(f::Fluid)
  c = f.fluid.heat_capacity
  μ = f.fluid.viscosity
  k = f.fluid.thermal_conductivity

  return c * μ / k
end

function nusselt_number_laminar(f::Flow)
  return 0.0
end

function nusselt_number_turbulent(f::Flow)
  return 0.0
end

function nusselt_number(f::Flow)
  γ = criticality(f)

  return (1 - γ) * nusselt_number_laminar(f) + γ * nusselt_number_turbulent(f)
end