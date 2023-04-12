@testset "Loop" begin

    @test Loop(current = 1u"A", radius = 10u"mm") == Loop(1u"A", 10u"mm", 0u"m")
    @test Loop(current = 1u"A", radius = 10u"mm", height = -5u"mm") == Loop(1u"A", 10u"mm", -5u"mm")

    @testset "conductor_coordinates" begin
        @test conductor_coordinates(Loop(current = 1u"A", radius = 10u"mm")) == [[10u"mm" 0u"mm"]]
        @test conductor_coordinates(Loop(current = 1u"A", radius = 10u"mm", height = -5u"mm")) ==
              [[10u"mm" -5u"mm"]]
    end

    @testset "conductor_length" begin
        @test conductor_length(Loop(current = 1u"A", radius = 10u"mm")) == 2π * 10u"mm"
    end

    @testset "mfd" begin
        current_loop = Loop(current = 300u"A", radius = 39.6u"mm", height = 26.5u"mm")

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

end