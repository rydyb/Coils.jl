import Unitful: Unitful
using DynamicQuantities

export IncompatibleUnitsError
export qconvert

struct IncompatibleUnitsError <: Exception
    got_unit::Any
    want_unit::Any
end

Base.showerror(io::IO, e::IncompatibleUnitsError) =
    print(io, "Expected ", e.want_unit, "but got ", e.got_unit)


function qconvert(x::AbstractQuantity, default_unit::AbstractQuantity)
    if dimension(x) != dimension(default_unit)
        throw(IncompatibleUnitsError(dimension(x), dimension(default_unit)))
    end
    return x
end

function qconvert(x::Number, default_unit::AbstractQuantity)
    return x * default_unit
end

function qconvert(x::Unitful.Quantity, default_unit::AbstractQuantity)
    y = convert(Quantity, x)
    if dimension(y) != dimension(default_unit)
        throw(IncompatibleUnitsError(y, default_unit))
    end
    return ustrip(y) * default_unit
end
