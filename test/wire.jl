@testset "RectangularSectionWithHole" begin

    section = RectangularSectionWithHole(height = 5u"mm", width = 5u"mm", diameter = 2.7u"mm")

    @test section == RectangularSectionWithHole(5u"mm", 5u"mm", 2.7u"mm", Copper)

    @testset "hollow_area" begin
        @test hollow_area(section) ≈ 5.73u"mm^2" atol = 1e-2u"mm^2"
    end

    @testset "conductive_area" begin
        @test conductive_area(section) ≈ 19.27u"mm^2" atol = 1e-2u"mm^2"
    end

    @testset "specific_resistance" begin
        @test specific_resistance(section) ≈ 8.716e-4u"Ω/m" atol = 1e-6u"Ω/m"
    end

end