@testset "wires" begin

    @test wires(CurrentLoop(1u"A", 10u"mm")) == [[10u"mm" 0u"mm"]]
    @test wires(CurrentLoop(1u"A", 10u"mm", -5u"mm")) == [[10u"mm" -5u"mm"]]
    @test wires(Solenoid(1u"A", 10u"mm", 2u"mm", UInt8(2))) ≈ [[10.0u"mm" -1.0u"mm"], [10.0u"mm" 1.0u"mm"]]
    #@test wires(Solenoid(1.0, 1.0, 1, 0.0, 2, 0.1)) == [[1.0 0.0], [1.1 0.0]]

end