@testset "Fluid" begin

    @test Water(velocity = 1u"m/s", temperature = 20u"°C") == Fluid(
        density = 997u"kg/m^3",
        velocity = 1u"m/s",
        viscosity = 1u"mPa*s",
        heat_capacity = 4186u"J/(kg*K)",
        thermal_conductivity = 0.591u"W/(m*K)",
        temperature = 20u"°C",
    )

    fluid = Water(velocity = 0.58u"m/s", temperature = 20u"°C")
    tube = Tube(diameter = 2.7u"mm", length = 9.5153u"m")

    @testset "reynolds_number" begin
        @test reynolds_number(fluid, tube) ≈ 1561 atol = 1
    end

    @testset "prandtl_number" begin
        @test prandtl_number(fluid) ≈ 7 atol = 1
    end

    @testset "criticality" begin
        @test criticality(fluid, tube) ≈ 0 atol = 1e-4
    end

    @testset "nusselt_number_laminar" begin
        @test nusselt_number_laminar(fluid, tube) ≈ 5 atol = 1
    end

    @testset "nusselt_number_turbulent" begin
        @test nusselt_number_turbulent(fluid, tube) ≈ 20 atol = 1
    end

    @testset "nusselt_number" begin
        @test nusselt_number(fluid, tube) ≈ 5 atol = 1
    end

    @testset "pressure_drop_tube" begin
        @test pressure_drop_tube(fluid, tube) ≈ 0.25u"bar" atol = 0.01u"bar"
    end

    @testset "pressure_drop_coil" begin
        @test pressure_drop_coil(fluid, CoiledTube(tube, diameter = 63.1u"mm", pitch = 2.6u"mm")) ≈
              0.26u"bar" atol = 0.01u"bar"
    end

end