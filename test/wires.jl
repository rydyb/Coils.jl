using Coils
using Test

@testset "wires" begin

    @test wires(CurrentLoop(1.0, 1.0)) == [[1.0 0.0]]

end