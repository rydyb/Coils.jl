@testset "Helical" begin

    @test Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 20u"mm",
        length = 2u"mm",
        radial_turns = UInt8(2),
        axial_turns = UInt8(3),
    ) == Helical(1u"A", 10u"mm", 20u"mm", 2u"mm", 0u"m", UInt8(2), UInt8(3))
    @test Pancake(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 20u"mm",
        turns = UInt8(2),
    ) == Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 20u"mm",
        length = 0u"m",
        radial_turns = UInt8(2),
        axial_turns = UInt8(1),
    )
    @test Pancake(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 20u"mm",
        turns = UInt8(2),
        height = 20u"mm",
    ) == Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 20u"mm",
        length = 0u"m",
        height = 20u"mm",
        radial_turns = UInt8(2),
        axial_turns = UInt8(1),
    )
    @test Solenoid(current = 1u"A", radius = 10u"mm", length = 6u"mm", turns = UInt8(6)) == Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 10u"mm",
        length = 6u"mm",
        axial_turns = UInt8(6),
    )
    @test Solenoid(
        current = 1u"A",
        radius = 10u"mm",
        length = 6u"mm",
        height = 40u"mm",
        turns = UInt8(6),
    ) == Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 10u"mm",
        length = 6u"mm",
        height = 40u"mm",
        axial_turns = UInt8(6),
    )

    @testset "mfdz" begin

        @test mfdz(
            Solenoid(current = 1u"A", radius = 5u"mm", length = 20u"mm", turns = UInt8(10)),
        ) ≈ [0.0, 5.62] .* u"Gauss" rtol = 1e-3
        @test mfdz(
            Solenoid(
                current = 1u"A",
                radius = 5u"mm",
                length = 20u"mm",
                height = 40u"mm",
                turns = UInt8(40),
            ),
        ) ≈ [0.0, 22.48] .* u"Gauss" rtol = 1e-4

    end

    @testset "total_inductance" begin

        @test total_inductance(
            Solenoid(current = 1u"A", radius = 5u"mm", length = 20u"mm", turns = UInt8(10)),
        ) ≈ 0.4u"μH" rtol = 0.1

    end

end