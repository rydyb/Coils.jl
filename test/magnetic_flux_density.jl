using LinearAlgebra: norm
using DynamicQuantities.Constants: mu_0

@testset "magnetic_flux_density" begin

    @testset "Coil" begin
        struct Coil <: AbstractCoil
            current::AbstractQuantity
        end
        coil = Coil(1u"A")

        @test_throws ErrorException magnetic_flux_density(coil, 0u"m", 0u"m")
    end

    @testset "CircularLoop" begin

        height = 26.5u"mm"

        loop = CircularLoop(current = 300u"A", diameter = 2*39.6u"mm")

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

        B1x, B1y, B1z = magnetic_flux_density(loop, 1u"mm", 1u"mm", 0u"m")
        B2ρ, B2z = magnetic_flux_density(loop, √2u"mm", 0u"m")
        @test B1z == B2z
        @test B1x^2 + B1y^2 == B2ρ^2
    end

    @testset "RectangularLoop" begin

        loop = RectangularLoop(current = 1u"A", width = 1u"m", height = 1u"m")

        Bx, By, Bz = magnetic_flux_density(loop, 0u"m", 0u"m", 0u"m")
        @test Bx ≈ 0.0u"Gauss" rtol = 1e-3
        @test By ≈ 0.0u"Gauss" rtol = 1e-3
        @test Bz ≈ √2 * mu_0 * loop.current / (1π * 0.5u"m") rtol = 1e-3
    end

    @testset "Superposition" begin
        cloop = CircularLoop(current = 1u"A", diameter = 1u"m")
        rloop = RectangularLoop(current = 1u"A", width = 1u"m", height = 1u"m")

        @test 2 .* magnetic_flux_density(cloop, 0u"m", 0u"m", 0u"m") ==
              magnetic_flux_density(Superposition([cloop, cloop]), 0u"m", 0u"m", 0u"m")

        @test 2 .* magnetic_flux_density(rloop, 0u"m", 0u"m", 0u"m") ==
              magnetic_flux_density(Superposition([rloop, rloop]), 0u"m", 0u"m", 0u"m")

        @test magnetic_flux_density(cloop, 0u"m", 0u"m", 0u"m") .+
              magnetic_flux_density(rloop, 0u"m", 0u"m", 0u"m") ==
              magnetic_flux_density(Superposition([rloop, cloop]), 0u"m", 0u"m", 0u"m")
    end

    @testset "Displace" begin
        cloop = CircularLoop(current = 1u"A", diameter = 1u"m")
        rloop = RectangularLoop(current = 1u"A", width = 1u"m", height = 1u"m")

        @test magnetic_flux_density(Displace(cloop, z = 0.5u"m"), 0u"m", 0u"m", 0u"m") ==
              magnetic_flux_density(cloop, 0u"m", 0u"m", -0.5u"m")
        @test magnetic_flux_density(Displace(rloop, z = -0.1u"m"), 0u"m", 0u"m", 0u"m") ==
              magnetic_flux_density(rloop, 0u"m", 0u"m", 0.1u"m")
    end

    @testset "Reverse" begin
        cloop = CircularLoop(current = 1u"A", diameter = 1u"m")
        rloop = RectangularLoop(current = 1u"A", width = 1u"m", height = 1u"m")

        @test magnetic_flux_density(Reverse(cloop), 0u"m", 0u"m", 0u"m") ==
              -1 .* magnetic_flux_density(cloop, 0u"m", 0u"m", 0u"m")
        @test magnetic_flux_density(Reverse(cloop), 0u"m", 0u"m", 0u"m") ==
              -1 .* magnetic_flux_density(cloop, 0u"m", 0u"m", 0u"m")
    end

    @testset "Helmholtz" begin
        # https://de.wikipedia.org/wiki/Helmholtz-Spule#Berechnuang_der_magnetischen_Flussdichte
        loop = CircularLoop(current = 1u"A", diameter = 2u"m")
        helmholtz = Helmholtz(loop, distance = 1u"m")

        @test magnetic_flux_density(helmholtz, 0u"m", 0u"m", 0u"m")[3] ≈ 0.899e-6u"T" rtol = 1e-3
    end

    @testset "AntiHelmholtz" begin
        loop = CircularLoop(current = 1u"A", diameter = 1u"m")
        ahelmholtz = AntiHelmholtz(loop, distance = 1u"m")

        @test magnetic_flux_density(ahelmholtz, 0u"m", 0u"m", 0u"m")[3] ≈ 0.0u"T" rtol = 1e-3
    end
end
