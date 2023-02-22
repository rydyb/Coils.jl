export wires

"""
    wires(c::CurrentLoop)

Returns the cylindrical coordinates of a current loop's wire.
"""
wires(c::CurrentLoop) = [[c.radius c.height]]

"""
    wires(sp::Superposition)

Returns the cylindrical coordinates of a superposition's wires.
"""
wires(sp::Superposition) = [ρz for c in sp.coils for ρz in wires(c)]

wires(c::Solenoid) = wires(Superposition(c))