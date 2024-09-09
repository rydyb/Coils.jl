@testset "conductor_length" begin

    cloop = CircularLoop(current = 1u"A", radius = 10u"mm")

    @testset "CircularLoop" begin
        @test conductor_length(cloop) == 2π * 10u"mm"
    end

    rloop = RectangularLoop(current = 1u"A", height = 10u"mm", width = 20u"mm")

    @testset "RectangularLoop" begin
        @test conductor_length(
            rloop
        ) == 60u"mm"
    end

    @testset "Translation" begin
        @test conductor_length(Translation(rloop, [0u"m", 0u"m", 10u"m"])) == conductor_length(rloop)
    end

    @testset "Superposition" begin
        @test conductor_length([
            CircularLoop(current = 1u"A", radius = 10u"mm")
            CircularLoop(current = 1u"A", radius = 20u"mm")
        ]) ≈ 2π * 30u"mm" rtol = 1e-4
        @test conductor_length([
            RectangularLoop(current = 1u"A", height = 10u"mm", width = 20u"mm")
            RectangularLoop(current = 1u"A", height = 5u"mm", width = 30u"mm")
        ]) == 130u"mm"
    end

end
