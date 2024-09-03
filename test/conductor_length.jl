@testset "conductor_length" begin

    @testset "CircularLoop" begin
        @test conductor_length(CircularLoop(current = 1u"A", radius = 10u"mm")) == 2π * 10u"mm"
    end

    @testset "RectangularLoop" begin
        @test conductor_length(
            RectangularLoop(current = 1u"A", height = 10u"mm", width = 20u"mm"),
        ) == 60u"mm"
    end
end
