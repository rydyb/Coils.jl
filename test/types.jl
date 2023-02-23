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

    @testset "Superposition" begin
        @test Superposition(Helical(1u"A", 10u"mm", 10u"mm", 0u"mm", UInt8(1), UInt8(1))) ==
              Superposition([CurrentLoop(1u"A", 10u"mm", 0.0u"m")])
    end

end