### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 162f2bf8-8480-11ef-0e6a-572667782062
begin
	import Pkg
	Pkg.activate(".")
end

# ╔═╡ aa2b0d06-2708-42e9-b2b9-877a58b9664b
begin
	using Coils
	using DynamicQuantities
	using LinearAlgebra
	using Plots
end

# ╔═╡ 5fc89931-ac7f-4f6b-baeb-6e213337233d
mfd(coil, ρ, z) = norm(magnetic_flux_density(coil, ρ, 0u"m", z))

# ╔═╡ 23a89706-ead9-47da-bfbe-2a679890848b
mfdρ(coil, ρ, z) = magnetic_flux_density(coil, ρ, 0u"m", z)[1]

# ╔═╡ bae5bcbd-37d4-4a01-a149-c6206bd36795
mfdϕ(coil, ρ, z) = magnetic_flux_density(coil, ρ, 0u"m", z)[2]

# ╔═╡ b77985a7-abd3-4852-ba80-87feb02205af
mfdz(coil, ρ, z) = magnetic_flux_density(coil, ρ, 0u"m", z)[3]

# ╔═╡ 62e6b885-7900-42b5-924b-ce18ae8380b9
loop = CircularLoop(current=1u"A", radius=1u"m")

# ╔═╡ 201d11b5-9a84-412e-be77-d314a7db0b62
md"## Helmholtz"

# ╔═╡ a3254a0c-d669-4a33-a102-87495ead9312
helmholtz = Helmholtz(loop, distance=1u"m")

# ╔═╡ 66add5e2-364e-4544-8c91-3cbec816e0b0
let
	z = range(-2u"m", 2u"m", 51)

	B1 = [mfdρ(helmholtz.coils[1], 0u"m", z) for z in z]
	B2 = [mfdρ(helmholtz.coils[2], 0u"m", z) for z in z]
	Bhelmholtz = [mfdρ(helmholtz, 0u"m", z) for z in z]

	md"Sum of all radial magnetic flux density components along axial direction: $(sum(B1),sum(B2))"
end

# ╔═╡ 932eb910-a15e-44b9-a245-5dd1fc4ea1c0
let
	z = range(-2u"m", 2u"m", 51)

	B1 = [mfdϕ(helmholtz.coils[1], 0u"m", z) for z in z]
	B2 = [mfdϕ(helmholtz.coils[2], 0u"m", z) for z in z]
	Bhelmholtz = [mfdϕ(helmholtz, 0u"m", z) for z in z]

	md"Sum of all angular magnetic flux density components along axial direction: $(sum(B1),sum(B2))"
end

# ╔═╡ 1e5b9289-10da-4400-9b42-2d838c2f1c59
let
	z = range(-2u"m", 2u"m", 51)

	B1 = [mfdz(helmholtz.coils[1], 0u"m", z) for z in z]
	B2 = [mfdz(helmholtz.coils[2], 0u"m", z) for z in z]
	Bhelmholtz = [mfdz(helmholtz, 0u"m", z) for z in z]
	
	plot(
		ustrip.(z),
		ustrip.([
			B1, B2, Bhelmholtz
		]) ./ 1e-4,
		label=["Bz₁" "Bz₂" "Bz₁+Bz₂"],
		markershape=[:circle :cross :star]
	)
	xlabel!("z/R")
	ylabel!("Bz (Gauss)")
end

# ╔═╡ 61ee4135-9cef-421f-a47e-ea82e679d61c
let
	ρ = range(-2u"m", 2u"m", 101)

	B1 = [mfdρ(helmholtz.coils[1], ρ, 0u"m") for ρ in ρ]
	B2 = [mfdρ(helmholtz.coils[2], ρ, 0u"m") for ρ in ρ]
	Bhelmholtz = [mfdρ(helmholtz, ρ, 0u"m") for ρ in ρ]

	md"Sum of all radial magnetic flux density components along radial direction: $(sum(B1),sum(B2))"
end

# ╔═╡ b5caef90-ac31-4689-8872-4d3ab3386dc8
let
	ρ = range(-2u"m", 2u"m", 101)

	B1 = [mfdϕ(helmholtz.coils[1], ρ, 0u"m") for ρ in ρ]
	B2 = [mfdϕ(helmholtz.coils[2], ρ, 0u"m") for ρ in ρ]
	Bhelmholtz = [mfdρ(helmholtz, ρ, 0u"m") for ρ in ρ]

	md"Sum of all angular magnetic flux density components along radial direction: $(sum(B1),sum(B2))"
end

# ╔═╡ 4dddd7c0-db87-497b-8d60-c6d2b6c52427
let
	ρ = range(-2u"m", 2u"m", 101)

	B1 = [mfdρ(helmholtz.coils[1], ρ, 0u"m") for ρ in ρ]
	B2 = [mfdρ(helmholtz.coils[2], ρ, 0u"m") for ρ in ρ]
	Bhelmholtz = [mfdρ(helmholtz, ρ, 0u"m") for ρ in ρ]
	
	scatter(
		ustrip.(ρ),
		ustrip.([
			B1, B2, Bhelmholtz
		]) ./ 1e-4,
		label=["Bz₁" "Bz₂" "Bz₁+Bz₂"],
		markershape=[:circle :cross :star]
	)
	title!("z = 0 mm")
	xlabel!("ρ/R")
	ylabel!("Bz (Gauss)")
end

# ╔═╡ ca0f1232-0203-4fb0-92b8-cd388bc4492f
let
	ρ = range(-2u"m", 2u"m", 101)
	z = 10u"mm"

	B1 = [mfdρ(helmholtz.coils[1], ρ, z) for ρ in ρ]
	B2 = [mfdρ(helmholtz.coils[2], ρ, z) for ρ in ρ]
	Bhelmholtz = [mfdρ(helmholtz, ρ, z) for ρ in ρ]
	
	scatter(
		ustrip.(ρ),
		ustrip.([
			B1, B2, Bhelmholtz
		]) ./ 1e-4,
		label=["Bz₁" "Bz₂" "Bz₁+Bz₂"],
		markershape=[:circle :cross :star]
	)
	title!("z = 10 mm")
	xlabel!("ρ/R")
	ylabel!("Bz (Gauss)")
end

# ╔═╡ 43311b7e-84ed-42b8-a241-f7728fdc03c6
mfdz(helmholtz, 0u"m", 0u"m"), mfd(helmholtz, 0u"m", 0u"m")

# ╔═╡ 1096c7c2-fe5b-493f-89da-3025ab7b39ec
let
	
	ρ = range(-2u"m", 2u"m", 100)
	z = range(-1u"m", 1u"m", 100)

	B = fill(NaN, size(ρ, 1), size(z, 1))

	for i in eachindex(ρ), j in eachindex(z)
    	B[j, i] = ustrip.(mfd(helmholtz, ρ[i], z[j])) ./ 1e-4
	end

	heatmap(ustrip.(ρ), ustrip.(z), ustrip.(B), colormap = :viridis, colorbar_title="Bz (Gauss)", clim=(0, 0.01))
	xlabel!("x/R")
	ylabel!("z/R")
end

# ╔═╡ 5071a082-4535-44f9-b66b-46d916d14000
md"## Anti-Helmholtz"

# ╔═╡ d2bb39e5-5396-4392-8123-456ef63b6a6a
ahelmholtz = AntiHelmholtz(loop, distance=1u"m")

# ╔═╡ afcca742-a020-4dda-846a-aadf45de6cdf
let
	z = range(-2u"m", 2u"m", 51)

	B1 = [mfdz(ahelmholtz.coils[1], 0u"m", z) for z in z]
	B2 = [mfdz(ahelmholtz.coils[2], 0u"m", z) for z in z]
	Bhelmholtz = [mfdz(ahelmholtz, 0u"m", z) for z in z]
	
	plot(
		ustrip.(z),
		ustrip.([
			B1, B2, Bhelmholtz
		]) ./ 1e-4,
		label=["Bz₁" "Bz₂" "Bz₁+Bz₂"],
		markershape=[:circle :cross :star]
	)
	xlabel!("Radial coordinate ρ/R (m)")
	ylabel!("Bz (Gauss)")
end

# ╔═╡ Cell order:
# ╟─162f2bf8-8480-11ef-0e6a-572667782062
# ╠═aa2b0d06-2708-42e9-b2b9-877a58b9664b
# ╟─5fc89931-ac7f-4f6b-baeb-6e213337233d
# ╟─23a89706-ead9-47da-bfbe-2a679890848b
# ╟─bae5bcbd-37d4-4a01-a149-c6206bd36795
# ╟─b77985a7-abd3-4852-ba80-87feb02205af
# ╠═62e6b885-7900-42b5-924b-ce18ae8380b9
# ╟─201d11b5-9a84-412e-be77-d314a7db0b62
# ╟─a3254a0c-d669-4a33-a102-87495ead9312
# ╟─66add5e2-364e-4544-8c91-3cbec816e0b0
# ╟─932eb910-a15e-44b9-a245-5dd1fc4ea1c0
# ╟─1e5b9289-10da-4400-9b42-2d838c2f1c59
# ╟─61ee4135-9cef-421f-a47e-ea82e679d61c
# ╟─b5caef90-ac31-4689-8872-4d3ab3386dc8
# ╟─4dddd7c0-db87-497b-8d60-c6d2b6c52427
# ╟─ca0f1232-0203-4fb0-92b8-cd388bc4492f
# ╠═43311b7e-84ed-42b8-a241-f7728fdc03c6
# ╠═1096c7c2-fe5b-493f-89da-3025ab7b39ec
# ╟─5071a082-4535-44f9-b66b-46d916d14000
# ╟─d2bb39e5-5396-4392-8123-456ef63b6a6a
# ╟─afcca742-a020-4dda-846a-aadf45de6cdf
