export RectangularSectionWithHole
export Copper
export hollow_area, conductive_area
export resistance, weight, heat_capacity

"""
    Material

A wire material with a name and resistivity.
"""
struct Material{T1<:Unitful.ElectricalResistivity,T2<:Unitful.Density,T3<:SpecificHeatCapacity}
    name::String
    resistivity::T1
    density::T2
    heat_capacity::T3
end

# https://en.wikipedia.org/wiki/Electrical_resistivity_and_conductivity#Resistivity_and_conductivity_of_various_materials
const Copper = Material("Copper", 1.68e-8u"Ω*m", 8.96u"g/cm^3", 0.385u"J/(g*K)")

"""
    Section

A wire cross-section.
"""
abstract type Section end

struct RectangularSectionWithHole{T1<:Unitful.Length,T2<:Unitful.Length,T3<:Unitful.Length,TM} <:
       Section
    height::T2
    width::T1
    diameter::T3
    material::Material{TM}
end

RectangularSectionWithHole(;
    width::Unitful.Length,
    height::Unitful.Length,
    diameter::Unitful.Length,
    material::Material = Copper,
) = RectangularSectionWithHole(height, width, diameter, material)

function hollow_area(w::RectangularSectionWithHole)
    d = w.diameter

    return π * (d / 2)^2
end

function conductive_area(wire::RectangularSectionWithHole)
    w = wire.width
    h = wire.height

    return w * h - hollow_area(wire)
end

function resistance(w::RectangularSectionWithHole)
    A = conductive_area(w)
    ρ = w.material.resistivity

    return uconvert(u"Ω/m", ρ / A)
end

function weight(w::RectangularSectionWithHole)
    A = conductive_area(w)
    ρ = w.material.density

    return uconvert(u"g/m", ρ * A)
end

function heat_capacity(w::RectangularSectionWithHole)
    m = weight(w)
    c = w.material.heat_capacity

    return uconvert(u"J/(K*m)", c * m)
end