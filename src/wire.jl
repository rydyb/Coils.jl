export RectangularSectionWithHole
export Copper
export hollow_area, conductive_area
export specific_resistance

"""
    Material

A wire material with a name and resistivity.
"""
struct Material{T1<:Unitful.ElectricalResistivity}
    name::String
    resistivity::T1
end

# https://en.wikipedia.org/wiki/Electrical_resistivity_and_conductivity#Resistivity_and_conductivity_of_various_materials
const Copper = Material("Copper", 1.68e-8u"Ω*m")

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

function specific_resistance(w::RectangularSectionWithHole)
    A = conductive_area(w)
    ρ = w.material.resistivity

    return uconvert(u"Ω/m", ρ / A)
end