@testset "CurrentLoop" begin

    @test CurrentLoop(current = 1u"A", radius = 10u"mm") == CurrentLoop(1u"A", 10u"mm", 0u"m")
    @test CurrentLoop(current = 1u"A", radius = 10u"mm", height = -5u"mm") ==
          CurrentLoop(1u"A", 10u"mm", -5u"mm")

    @testset "mfd" begin
        current_loop = CurrentLoop(current = 300u"A", radius = 39.6u"mm", height = 26.5u"mm")

        # should equal results from Comsol 5.5 simulation (wire diameter = 1.0 mm)
        comsol = [
            (0u"mm", -5u"mm", 22.81u"Gauss"),
            (0u"mm", -4u"mm", 23.67u"Gauss"),
            (0u"mm", -3u"mm", 24.54u"Gauss"),
            (0u"mm", -2u"mm", 25.54u"Gauss"),
            (0u"mm", -1u"mm", 26.37u"Gauss"),
            (0u"mm", 0u"mm", 27.31u"Gauss"),
            (0u"mm", 1u"mm", 28.28u"Gauss"),
            (0u"mm", 2u"mm", 29.26u"Gauss"),
            (0u"mm", 3u"mm", 30.26u"Gauss"),
            (0u"mm", 4u"mm", 31.27u"Gauss"),
            (0u"mm", 5u"mm", 32.29u"Gauss"),
            (0u"mm", 0u"mm", 27.31u"Gauss"),
            (1u"mm", 0u"mm", 27.31u"Gauss"),
            (2u"mm", 0u"mm", 27.31u"Gauss"),
            (3u"mm", 0u"mm", 27.30u"Gauss"),
            (4u"mm", 0u"mm", 27.30u"Gauss"),
            (5u"mm", 0u"mm", 27.29u"Gauss"),
            (6u"mm", 0u"mm", 27.28u"Gauss"),
            (7u"mm", 0u"mm", 27.26u"Gauss"),
            (8u"mm", 0u"mm", 27.26u"Gauss"),
            (9u"mm", 0u"mm", 27.24u"Gauss"),
            (10u"mm", 0u"mm", 27.23u"Gauss"),
        ]
        for (ρ, z, B) in comsol
            @test round(u"Gauss", norm(mfd(current_loop, ρ, z)); sigdigits = 4) ≈ B atol =
                0.1u"Gauss"
        end

        # should reduce to simple analytical solution along the z-axis
        @test mfd(current_loop, 0u"m", 0u"m") ≈ mfd_z(current_loop, 0u"m") atol = 0.01u"T"
    end

    @testset "conductor_coordinates" begin
        @test conductor_coordinates(CurrentLoop(current = 1u"A", radius = 10u"mm")) ==
              [[10u"mm" 0u"mm"]]
        @test conductor_coordinates(
            CurrentLoop(current = 1u"A", radius = 10u"mm", height = -5u"mm"),
        ) == [[10u"mm" -5u"mm"]]
    end

    @testset "conductor_length" begin
        @test conductor_length(CurrentLoop(current = 1u"A", radius = 10u"mm")) == 2π * 10u"mm"
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
end

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