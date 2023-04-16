@testset "Helmholtz" begin

    coil = Helical(
        current = 1u"A",
        inner_radius = 10u"mm",
        outer_radius = 12u"mm",
        length = 20u"mm",
        axial_turns = UInt8(2),
        radial_turns = UInt8(3),
    )

    @test Helmholtz(coil = coil, separation = 100u"mm") == Helmholtz(coil, 100u"mm", 1)

    @test AntiHelmholtz(coil = coil, separation = 100u"mm") == Helmholtz(coil, 100u"mm", -1)

    @testset "mfdz" begin

        @test mfdz(
            Helmholtz(
                coil = Pancake(
                    current = 1u"A",
                    inner_radius = 1u"m",
                    outer_radius = 1u"m",
                    turns = UInt8(1),
                ),
            ),
        ) ≈ [0.0, 8.99e-3] .* u"Gauss" rtol = 1e-3

        @test mfdz(AntiHelmholtz(coil = coil)) == [0.0, 0.0] .* u"Gauss"

    end

    @testset "self_inductance" begin

        @test self_inductance(Helmholtz(coil = coil)) == total_inductance(coil)

    end

    @testset "mutual_inductance" begin

        @test mutual_inductance(Helmholtz(coil = coil)) ≈ 0.196u"μH" rtol = 1e-2

    end

end