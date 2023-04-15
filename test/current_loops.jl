@testset "CurrentLoops" begin

    @testset "Helical" begin

        @test CurrentLoops(
            Helical(
                current=1u"A",
                inner_radius=10u"mm",
                outer_radius=10u"mm",
                length=0u"m",
            ),
        ) == [CurrentLoop(current=1u"A", radius=10.0u"mm")]

        @test CurrentLoops(
            Solenoid(current=1u"A", radius=10u"mm", length=2u"mm", turns=UInt8(2)),
        ) == [
            CurrentLoop(current=1u"A", radius=10.0u"mm", height=-0.001u"m"),
            CurrentLoop(current=1u"A", radius=10.0u"mm", height=0.001u"m"),
        ]

        @test CurrentLoops(
            Pancake(
                current=1u"A",
                inner_radius=10u"mm",
                outer_radius=12u"mm",
                turns=UInt8(2),
            ),
        ) == [
            CurrentLoop(current=1u"A", radius=10.0u"mm"),
            CurrentLoop(current=1u"A", radius=12.0u"mm"),
        ]

    end

    @testset "Helmholtz" begin
        coil = Pancake(
            current=1u"A",
            inner_radius=10u"mm",
            outer_radius=12u"mm",
            turns=UInt8(2),
        )

        @test CurrentLoops(Helmholtz(coil=coil, separation=100u"mm")) == [
            CurrentLoop(current=1u"A", radius=10.0u"mm", height=0.05u"m"),
            CurrentLoop(current=1u"A", radius=12.0u"mm", height=0.05u"m"),
            CurrentLoop(current=1u"A", radius=10.0u"mm", height=-0.05u"m"),
            CurrentLoop(current=1u"A", radius=12.0u"mm", height=-0.05u"m"),
        ]
    end

    current_loops = [
        CurrentLoop(current=1u"A", radius=10.0u"mm", height=-1u"mm")
        CurrentLoop(current=1u"A", radius=12.0u"mm", height=2u"mm")
    ]

    @testset "conductor_coordinates" begin
        @test conductor_coordinates(current_loops) == [(10.0u"mm", -1u"mm"), (12.0u"mm", 2u"mm")]
    end

    @testset "conductor_length" begin
        @test conductor_length(current_loops) == 2π * 22u"mm"

    end

    @testset "mfd" begin
        ρ = 0u"m"
        z = 4u"mm"

        @test mfd(current_loops, ρ, z) == [
            mfd(current_loops[1], ρ, z)[1] + mfd(current_loops[2], ρ, z)[1],
            mfd(current_loops[1], ρ, z)[2] + mfd(current_loops[2], ρ, z)[2],
        ]
    end

end