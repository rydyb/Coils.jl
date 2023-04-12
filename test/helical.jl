@testset "Helical" begin

    @test Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 20u"mm",
        length = 2u"mm",
        radial_turns = UInt8(2),
        axial_turns = UInt8(3),
    ) == Helical(1u"A", 10u"mm", 20u"mm", 2u"mm", 0u"m", (UInt8(2), UInt8(3)))
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

    @testset "mfd" begin
        solenoid = Solenoid(current = 10u"A", radius = 10u"mm", length = 40u"mm", turns = UInt8(20))

        @test mfd(solenoid, 0u"m", 0u"m") ≈ mfd_z(solenoid, 0u"m") atol = 0.1u"T"
    end

    @testset "conductor_coordinates" begin
        @test conductor_coordinates(
            Solenoid(current = 1u"A", radius = 10u"mm", length = 2u"mm", turns = UInt8(2)),
        ) == [[10.0u"mm" -1.0u"mm"], [10.0u"mm" 1.0u"mm"]]
        @test conductor_coordinates(
            Pancake(
                current = 1u"A",
                inner_radius = 10u"mm",
                outer_radius = 20u"mm",
                turns = UInt8(2),
            ),
        ) == [[10.0u"mm" 0.0u"mm"], [20.0u"mm" 0.0u"mm"]]
        @test conductor_coordinates(
            Helical(
                current = 1u"A",
                inner_radius = 10u"mm",
                outer_radius = 20u"mm",
                length = 2u"mm",
                radial_turns = UInt8(2),
                axial_turns = UInt8(2),
            ),
        ) == [
            [10.0u"mm" -1.0u"mm"],
            [10.0u"mm" 1.0u"mm"],
            [20.0u"mm" -1.0u"mm"],
            [20.0u"mm" 1.0u"mm"],
        ]
    end

    @testset "conductor_length" begin
        @test conductor_length(
            Pancake(
                current = 1u"A",
                inner_radius = 10u"mm",
                outer_radius = 20u"mm",
                turns = UInt8(2),
            ),
        ) == 2π * 30u"mm"
    end
end