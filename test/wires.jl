@testset "wires" begin

    @testset "CurrentLoop" begin
        @test wires(CurrentLoop(1u"A", 10u"mm")) == [[10u"mm" 0u"mm"]]
        @test wires(CurrentLoop(1u"A", 10u"mm", -5u"mm")) == [[10u"mm" -5u"mm"]]
    end

    @testset "Helical" begin
        @test wires(Solenoid(1u"A", 10u"mm", 2u"mm", UInt8(2))) ==
              [[10.0u"mm" -1.0u"mm"], [10.0u"mm" 1.0u"mm"]]
        @test wires(Pancake(1u"A", 10u"mm", 20u"mm", UInt8(2))) ==
              [[10.0u"mm" 0.0u"mm"], [20.0u"mm" 0.0u"mm"]]
        @test wires(Helical(1u"A", 10u"mm", 20u"mm", 2u"mm", UInt8(2), UInt8(2))) == [
            [10.0u"mm" -1.0u"mm"],
            [10.0u"mm" 1.0u"mm"],
            [20.0u"mm" -1.0u"mm"],
            [20.0u"mm" 1.0u"mm"],
        ]
    end

end