@testset "Pair" begin

    coil = Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 12u"mm",
        length = 20u"mm",
        axial_turns = UInt8(2),
        radial_turns = UInt8(3),
    )

    @test Helmholtz(coil = coil, separation = 100u"mm") == CoilPair(
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

    @test AntiHelmholtz(coil = coil, separation = 100u"mm") == CoilPair(
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

    cp = Helmholtz(
        coil = Pancake(
            current = 100u"A",
            inner_radius = 10u"mm",
            outer_radius = 10u"mm",
            turns = UInt8(1),
        ),
    )

    @testset "mfd" begin
        @test mfd(cp, 0u"m", 0u"m") ≈ [0u"T" 0u"T"] atol = 0.1u"T"
        @test mfd(cp, 1u"μm", 0u"m") ≈ mfd_z(cp, 0u"m") atol = 0.1u"T"
    end

    @testset "conductor_coordinates" begin
        @test conductor_coordinates(cp) == [[10.0u"mm" 0.005u"m"], [10.0u"mm" -0.005u"m"]]
    end
end