@testset "CurrentLoop" begin

    @test CurrentLoop(current = 1u"A", radius = 10u"mm") == CurrentLoop(1u"A", 10u"mm", 0u"m")
    @test CurrentLoop(current = 1u"A", radius = 10u"mm", height = -5u"mm") ==
          CurrentLoop(1u"A", 10u"mm", -5u"mm")

    @testset "mfd" begin
        current_loop = CurrentLoop(current = 1u"A", radius = 1u"m")

        @test mfd(current_loop, 0u"m", 0u"m") ≈ mfd_z(current_loop, 0u"m")
    end

    @testset "conductor" begin
        @test conductor(CurrentLoop(current = 1u"A", radius = 10u"mm")) == [[10u"mm" 0u"mm"]]
        @test conductor(CurrentLoop(current = 1u"A", radius = 10u"mm", height = -5u"mm")) ==
              [[10u"mm" -5u"mm"]]
    end

end

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

    @testset "conductor" begin
        @test conductor(
            Solenoid(current = 1u"A", radius = 10u"mm", length = 2u"mm", turns = UInt8(2)),
        ) == [[10.0u"mm" -1.0u"mm"], [10.0u"mm" 1.0u"mm"]]
        @test conductor(
            Pancake(
                current = 1u"A",
                inner_radius = 10u"mm",
                outer_radius = 20u"mm",
                turns = UInt8(2),
            ),
        ) == [[10.0u"mm" 0.0u"mm"], [20.0u"mm" 0.0u"mm"]]
        @test conductor(
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
end

@testset "Helmholtz" begin
    @test Helmholtz(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 14u"mm",
        length = 12u"mm",
        radial_turns = UInt8(2),
        axial_turns = UInt8(3),
        separation = 100u"mm",
    ) == Helmholtz(1u"A", 10u"mm", 14u"mm", 12u"mm", 100u"mm", (UInt8(2), UInt8(3)))
    @test Helmholtz(current = 1u"A", inner_radius = 10u"mm") == Helmholtz(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 10u"mm",
        length = 0u"m",
        radial_turns = UInt8(1),
        axial_turns = UInt8(1),
        separation = 10.0u"mm",
    )
end

@testset "AntiHelmholtz" begin

end

@testset "Superposition" begin
    @test Superposition(
        Helical(current = 1u"A", inner_radius = 10u"mm", outer_radius = 10u"mm", length = 0u"m"),
    ) == Superposition([CurrentLoop(current = 1u"A", radius = 10.0u"mm")])
    @test Superposition(
        Solenoid(current = 1u"A", radius = 10u"mm", length = 2u"mm", turns = UInt8(2)),
    ) == Superposition([
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = -0.001u"m"),
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = 0.001u"m"),
    ])
    @test Superposition(
        Pancake(current = 1u"A", inner_radius = 10u"mm", outer_radius = 12u"mm", turns = UInt8(2)),
    ) == Superposition([
        CurrentLoop(current = 1u"A", radius = 10.0u"mm"),
        CurrentLoop(current = 1u"A", radius = 12.0u"mm"),
    ])
    @test Superposition(
        Helmholtz(current = 1u"A", inner_radius = 10u"mm", outer_radius = 10u"mm", length = 0u"mm"),
    ) == Superposition([
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = 5.0u"mm"),
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = -5.0u"mm"),
    ])
    @test Superposition(
        AntiHelmholtz(
            current = 1u"A",
            inner_radius = 10u"mm",
            outer_radius = 10u"mm",
            length = 0u"mm",
            separation = 10u"mm",
        ),
    ) == Superposition([
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = 5.0u"mm"),
        CurrentLoop(current = -1u"A", radius = 10.0u"mm", height = -5.0u"mm"),
    ])
end