import Unitful: Unitful
using DynamicQuantities

export qconvert

struct IncompatibleUnitsError <: Exception
    got_unit::Any
    want_unit::Any
end

Base.showerror(io::IO, e::IncompatibleUnitsError) =
    print(io, "Expected ", e.want_unit, "but got ", e.got_unit)


function qconvert(x::AbstractQuantity, default_unit::AbstractQuantity)
    # TODO: check for dimensional compatibility
    return x
end

function qconvert(x::Number, default_unit::AbstractQuantity)
    return x * default_unit
end

function qconvert(x::Unitful.Quantity, default_unit::AbstractQuantity)
    # TODO: check for dimensional compatibility
    return Unitful.ustrip(x) * default_unit
end
