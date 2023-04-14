@testset "Helmholtz" begin

    coil = Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 12u"mm",
        length = 20u"mm",
        axial_turns = UInt8(2),
        radial_turns = UInt8(3),
    )

    @test Helmholtz(coil = coil, separation = 100u"mm") == (
        Helical(
            current = 1u"A",
            inner_radius = 10u"mm",
            outer_radius = 12u"mm",
            length = 20u"mm",
            axial_turns = UInt8(2),
            radial_turns = UInt8(3),
            height = 0.05u"m",
        ),
        Helical(
            current = 1u"A",
            inner_radius = 10u"mm",
            outer_radius = 12u"mm",
            length = 20u"mm",
            axial_turns = UInt8(2),
            radial_turns = UInt8(3),
            height = -0.05u"m",
        ),
    )

    @test AntiHelmholtz(coil = coil, separation = 100u"mm") == (
        Helical(
            current = 1u"A",
            inner_radius = 10u"mm",
            outer_radius = 12u"mm",
            length = 20u"mm",
            axial_turns = UInt8(2),
            radial_turns = UInt8(3),
            height = 0.05u"m",
        ),
        Helical(
            current = -1u"A",
            inner_radius = 10u"mm",
            outer_radius = 12u"mm",
            length = 20u"mm",
            axial_turns = UInt8(2),
            radial_turns = UInt8(3),
            height = -0.05u"m",
        ),
    )

end