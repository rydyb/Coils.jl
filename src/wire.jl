export wires

abstract type Wire end

struct RectangularHollowCore{T1<:Unitful.Length,T2<:Unitful.Length} <: Wire
    width::T1
    height::T1
    diameter::T1
    length::T2
end