@testset "conductor_length" begin

    cloop = CircularLoop(current = 1u"A", diameter = 10u"mm")

    @testset "CircularLoop" begin
        @test conductor_length(cloop) == π * 10u"mm"
    end

    rloop = RectangularLoop(current = 1u"A", height = 10u"mm", width = 20u"mm")

    @testset "RectangularLoop" begin
        @test conductor_length(rloop) == 60u"mm"
    end

    @testset "Displace" begin
        @test conductor_length(Displace(rloop; z = 10u"m")) == conductor_length(rloop)
    end

    @testset "Reverse" begin
        @test conductor_length(Reverse(rloop)) == conductor_length(rloop)
    end

    @testset "Superposition" begin
        @test conductor_length(
            Superposition(
                [
                    CircularLoop(current = 1u"A", diameter = 10u"mm")
                    CircularLoop(current = 1u"A", diameter = 20u"mm")
                ],
            ),
        ) ≈ π * 30u"mm" rtol = 1e-4
        @test conductor_length(
            Superposition(
                [
                    RectangularLoop(current = 1u"A", height = 10u"mm", width = 20u"mm")
                    RectangularLoop(current = 1u"A", height = 5u"mm", width = 30u"mm")
                ],
            ),
        ) == 130u"mm"
    end

end
