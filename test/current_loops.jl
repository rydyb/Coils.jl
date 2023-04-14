@testset "CurrentLoops" begin

    @test CurrentLoops(
        Helical(current = 1u"A", inner_radius = 10u"mm", outer_radius = 10u"mm", length = 0u"m"),
    ) == [CurrentLoop(current = 1u"A", radius = 10.0u"mm")]

    @test CurrentLoops(
        Solenoid(current = 1u"A", radius = 10u"mm", length = 2u"mm", turns = UInt8(2)),
    ) == [
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = -0.001u"m"),
        CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = 0.001u"m"),
    ]

    @test CurrentLoops(
        Pancake(current = 1u"A", inner_radius = 10u"mm", outer_radius = 12u"mm", turns = UInt8(2)),
    ) == [
        CurrentLoop(current = 1u"A", radius = 10.0u"mm"),
        CurrentLoop(current = 1u"A", radius = 12.0u"mm"),
    ]

    @testset "mfd" begin

    end

    @testset "conductor_coordinates" begin
        @test conductor_coordinates(
            [
                CurrentLoop(current = 1u"A", radius = 10.0u"mm", height = -1u"mm")
                CurrentLoop(current = 1u"A", radius = 12.0u"mm", height = 2u"mm")
            ],
        ) == [(10.0u"mm", -1u"mm"), (12.0u"mm", 2u"mm")]
    end

    @testset "conductor_length" begin

    end

end