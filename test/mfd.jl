using Unitful
using PhysicalConstants.CODATA2018: μ_0

# https://de.wikipedia.org/wiki/Leiterschleife
current_loop_mfd_z(I, R, z) = (μ_0 * I / 2) * R^2 / (R^2 + z^2)^(3 / 2)

# https://en.wikipedia.org/wiki/Solenoid
solenoid_mfd_z(I, N, L) = μ_0 * I * N / L / 1e4

@testset "mfd" begin

  @test mfd(CurrentLoop(1.0, 1.0), 0.0, 0.0)[2] ≈ current_loop_mfd_z(1.0, 1.0, 0.0) atol = 1e-4
  @test mfd(Solenoid(1.0, 1.0, 40, 1e-3, 1, 0.0), 0.0, 0.0)[2] ≈ solenoid_mfd_z(1.0, 40, 40e-3) atol = 1e-4

end