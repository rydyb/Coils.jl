@testset "types" begin

    @testset "CurrentLoop" begin
        @test CurrentLoop(1u"A", 10u"mm") == CurrentLoop(1u"A", 10u"mm", 0u"m")
        @test CurrentLoop(1u"A", 10u"mm", -5u"mm") == CurrentLoop(1u"A", 10u"mm", -5u"mm")
    end

    @testset "Helical" begin
        @test Helical(1u"A", 10u"mm", 20u"mm", 2u"mm", UInt8(2), UInt8(2)) ==
              Helical(1u"A", 10u"mm", 20u"mm", 2u"mm", UInt8(2), UInt8(2), 0u"m")
        @test Pancake(1u"A", 10u"mm", 20u"mm", UInt8(2)) ==
              Helical(1u"A", 10u"mm", 20u"mm", 0u"m", UInt8(1), UInt8(2), 0u"m")
        @test Pancake(1u"A", 10u"mm", 20u"mm", UInt8(2), 10u"mm") ==
              Helical(1u"A", 10u"mm", 20u"mm", 0u"m", UInt8(1), UInt8(2), 10u"mm")
        @test Solenoid(1u"A", 10u"mm", 6u"mm", UInt8(6)) ==
              Helical(1u"A", 10u"mm", 10u"mm", 6u"mm", UInt8(6), UInt8(1), 0u"m")
        @test Solenoid(1u"A", 10u"mm", 6u"mm", UInt8(6), 20u"mm") ==
              Helical(1u"A", 10u"mm", 10u"mm", 6u"mm", UInt8(6), UInt8(1), 20u"mm")
    end

    @testset "Helmholtz" begin
        @test Helmholtz(1u"A", 10u"mm", 14u"mm", 0u"mm", UInt8(1), UInt8(2)) ==
              Helmholtz(1u"A", 10u"mm", 14u"mm", 0u"mm", UInt8(1), UInt8(2), 12.0u"mm")
    end

    @testset "Superposition" begin
        @test Superposition(Helical(1u"A", 10u"mm", 10u"mm", 0u"mm", UInt8(1), UInt8(1))) ==
              Superposition([CurrentLoop(1u"A", 10.0u"mm")])
        @test Superposition(Helical(1u"A", 10u"mm", 10u"mm", 2u"mm", UInt8(2), UInt8(1))) ==
              Superposition([
            CurrentLoop(1u"A", 10.0u"mm", -0.001u"m"),
            CurrentLoop(1u"A", 10.0u"mm", 0.001u"m"),
        ])
        @test Superposition(Helical(1u"A", 10u"mm", 12u"mm", 0u"mm", UInt8(1), UInt8(2))) ==
              Superposition([CurrentLoop(1u"A", 10.0u"mm"), CurrentLoop(1u"A", 12.0u"mm")])
        @test Superposition(Helmholtz(1u"A", 10u"mm", 10u"mm", 0u"mm", UInt8(1), UInt8(1))) ==
              Superposition([
            CurrentLoop(1u"A", 10.0u"mm", 5.0u"mm"),
            CurrentLoop(1u"A", 10.0u"mm", -5.0u"mm"),
        ])
    end

end