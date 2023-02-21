@testset "wires" begin

    @test wires(CurrentLoop(1.0, 1.0)) == [[1.0 0.0]]
    @test wires(AxialOffset(CurrentLoop(1.0, 1.0), 1.0)) == [[1.0 1.0]]
    @test wires(Solenoid(1.0, 1.0, 2, 0.1, 1, 0.0)) == [[1.0 -0.05], [1.0 0.05]]
    @test wires(Solenoid(1.0, 1.0, 1, 0.0, 2, 0.1)) == [[1.0 0.0], [1.1 0.0]]

end