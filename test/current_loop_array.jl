@testset "CurrentLoopArray" begin

    @test CurrentLoopArray(
        Helical(current = 1u"A", inner_radius = 10u"mm", outer_radius = 10u"mm", length = 0u"m"),
    ) == [CurrentLoop(current = 1u"A", radius = 10.0u"mm")]

    @test CurrentLoopArray(
        Solenoid(current = 1u"A", radius = 10u"mm", length = 2u"mm", turns = UInt8(2)),
    ) == [
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = -0.001u"m"),
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = 0.001u"m"),
    ]

    @test CurrentLoopArray(
        Pancake(current = 1u"A", inner_radius = 10u"mm", outer_radius = 12u"mm", turns = UInt8(2)),
    ) == [
        CurrentLoop(current = 1u"A", radius = 10.0u"mm"),
        CurrentLoop(current = 1u"A", radius = 12.0u"mm"),
    ]

    @testset "mfd" begin

    end

    @testset "conductor_coordinates" begin

    end

    @testset "conductor_length" begin

    end

end