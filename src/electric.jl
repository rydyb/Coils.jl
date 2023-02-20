struct Wire
  length::Float64
  resistance::Float64
end

function resistance(Ω::Float64, A::Float64, V::Float64)
  return Ω * A / V
end