using LinearAlgebra: norm
using DynamicQuantities.Constants: mu_0

@testset "magnetic_flux_density" begin

    @testset "Coil" begin
        struct SomeCoil <: Coil
            current::AbstractQuantity
        end
        coil = SomeCoil(1u"A")

        @test_throws ErrorException magnetic_flux_density(coil, 0u"m", 0u"m")
    end

    @testset "CircularLoop" begin

        height = 26.5u"mm"

        loop = CircularLoop(current = 300u"A", radius = 39.6u"mm")

        # should equal results from Comsol 5.5 simulation (wire diameter = 1.0 mm)
        comsol = [
            (0u"mm", -5u"mm", 22.81u"Gauss"),
            (0u"mm", -4u"mm", 23.67u"Gauss"),
            (0u"mm", -3u"mm", 24.54u"Gauss"),
            (0u"mm", -2u"mm", 25.45u"Gauss"),
            (0u"mm", -1u"mm", 26.37u"Gauss"),
            (0u"mm", 0u"mm", 27.31u"Gauss"),
            (0u"mm", 1u"mm", 28.28u"Gauss"),
            (0u"mm", 2u"mm", 29.26u"Gauss"),
            (0u"mm", 3u"mm", 30.26u"Gauss"),
            (0u"mm", 4u"mm", 31.27u"Gauss"),
            (0u"mm", 5u"mm", 32.29u"Gauss"),
            (0u"mm", 0u"mm", 27.31u"Gauss"),
            (1u"mm", 0u"mm", 27.31u"Gauss"),
            (2u"mm", 0u"mm", 27.31u"Gauss"),
            (3u"mm", 0u"mm", 27.30u"Gauss"),
            (4u"mm", 0u"mm", 27.30u"Gauss"),
            (5u"mm", 0u"mm", 27.29u"Gauss"),
            (6u"mm", 0u"mm", 27.28u"Gauss"),
            (7u"mm", 0u"mm", 27.26u"Gauss"),
            (8u"mm", 0u"mm", 27.26u"Gauss"),
            (9u"mm", 0u"mm", 27.24u"Gauss"),
            (10u"mm", 0u"mm", 27.23u"Gauss"),
        ]
        for (ρ, z, B) in comsol
            @test norm(magnetic_flux_density(loop, ρ, z - height)) ≈ B rtol = 1e-3
        end
    end

    @testset "RectangularLoop" begin

        loop = RectangularLoop(current = 1u"A", width = 1u"m", height = 1u"m")

        Bx, By, Bz = magnetic_flux_density(loop, 0u"m", 0u"m", 0u"m")
        @test Bx ≈ 0.0u"Gauss" rtol = 1e-3
        @test By ≈ 0.0u"Gauss" rtol = 1e-3
        @test Bz ≈ √2 * mu_0 * loop.current / (1π * 0.5u"m") rtol = 1e-3
    end

    @testset "Helmholtz" begin
        # https://de.wikipedia.org/wiki/Helmholtz-Spule#Berechnung_der_magnetischen_Flussdichte
        loop = CircularLoop(current = 1u"A", radius = 1u"m")

        B = magnetic_flux_density(
            [Displace(loop; z = 0.5u"m"), Displace(loop; z = -0.5u"m")],
            0u"m",
            0u"m",
            0u"m",
        )

        @test B[3] ≈ 0.899e-6u"T" rtol = 1e-3
    end

    @testset "Anti-Helmholtz" begin
        loop = CircularLoop(current = 1u"A", radius = 1u"m")

        B = magnetic_flux_density(
            [Displace(loop; z = 0.5u"m"), Displace(Reverse(loop); z = -0.5u"m")],
            0u"m",
            0u"m",
            0u"m",
        )

        @test B[3] ≈ 0.0u"T" rtol = 1e-3
    end
end
