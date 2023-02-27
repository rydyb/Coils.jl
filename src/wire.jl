export RectangularHollowCore
export Copper
export hollow_area, total_resistance, dissipated_heat

abstract type Wire end

struct Material{T1<:Unitful.ElectricalResistivity}
    name::String
    resistivity::T1
end

const Copper = Material("Copper", 1.72e-8u"Ω*m")

struct RectangularHollowCore{T1<:Unitful.Length,T2<:Unitful.Length,T3} <: Wire
    width::T1
    height::T1
    core_diameter::T1
    total_length::T2
    material::Material{T3}
end

function hollow_area(w::RectangularHollowCore)
    d = w.core_diameter

    return π * (d / 2)^2
end

function conductive_area(wire::RectangularHollowCore)
    w = wire.width
    h = wire.height

    return w * h - hollow_area(wire)
end

function total_resistance(w::RectangularHollowCore)
    A = conductive_area(w)
    ρ = w.material.resistivity
    L = w.total_length

    return ρ * A / L
end

function heat_emission(w::RectangularHollowCore, current::Unitful.Current)
    R = total_resistance(w)
    I = current

    return R * I^2
end