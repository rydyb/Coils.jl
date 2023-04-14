export Helmholtz, AntiHelmholtz
export inductance

function Helmholtz(;
    coil::Helical,
    separation::Unitful.Length = (coil.outer_radius + coil.inner_radius) / 2,
)
    top = Helical(
        current = coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height + separation / 2,
        radial_turns = coil.radial_turns,
        axial_turns = coil.axial_turns,
    )
    bottom = Helical(
        current = coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height - separation / 2,
        radial_turns = coil.radial_turns,
        axial_turns = coil.axial_turns,
    )

    return (top, bottom)
end

function AntiHelmholtz(;
    coil::Helical,
    separation::Unitful.Length = √3 * (coil.outer_radius + coil.inner_radius) / 2,
)
    top = Helical(
        current = coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height + separation / 2,
        radial_turns = coil.radial_turns,
        axial_turns = coil.axial_turns,
    )
    bottom = Helical(
        current = -coil.current,
        inner_radius = coil.inner_radius,
        outer_radius = coil.outer_radius,
        length = coil.length,
        height = coil.height - separation / 2,
        radial_turns = coil.radial_turns,
        axial_turns = coil.axial_turns,
    )

    return (top, bottom)
end

function inductance(c::Tuple{Helical,Helical})
    N = Int(c[1].radial_turns) * Int(c[2].axial_turns)
    R = (cp.top.inner_radius + cp.top.outer_radius) / 2
    L = cp.top.length

    C = 2μ_0 * R * N^2
    L1 = π * R / (L + 2R / 2.2)
    L2 = 4.941 / 4π

    if ishelmholtz(cp)
        return C * (L1 + L2)
    end

    if isantihelmholtz(cp)
        return C * (L1 - L2)
    end

    throw(ArgumentError("Can only give the inductance for Helmholtz or anti-Helmholtz coils"))
end