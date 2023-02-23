@testset "mfd" begin

    @testset "CurrentLoop" begin
        current_loop = CurrentLoop(1u"A", 1u"m")

        @test mfd(current_loop, 0u"m", 0u"m") ≈ mfd_z(current_loop, 0u"m")
    end

    @testset "Solenoid" begin
        solenoid = Solenoid(10u"A", 10u"mm", 40u"mm", UInt8(20))

        @test mfd(solenoid, 0u"m", 0u"m") ≈ mfd_z(solenoid, 0u"m") atol = 0.1u"T"
    end

end