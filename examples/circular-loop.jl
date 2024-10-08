### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 0a823f86-84ce-11ef-3769-85b3a340da52
begin
	import Pkg
	Pkg.activate(".")
end

# ╔═╡ 5ada996f-8938-4a8a-92e6-98addd151079
begin
	using Coils
	using LinearAlgebra
	using DynamicQuantities
	using Plots
end

# ╔═╡ b6d76845-3a1d-4942-bc23-953314c175c7
md"# Circular loop"

# ╔═╡ f57cb21c-ad20-4965-87a0-6d750913e5cf
md"## Single loop"

# ╔═╡ 3c6d5660-30d5-4cda-b7bc-44c4a5c4b93e
loop = CircularLoop(current=1u"A", radius=40u"mm")

# ╔═╡ 56ce9aef-4b7f-4790-9cea-85a9ae1e5068
let
	z = range(-100u"mm", 100u"mm", 50)

	plot(
		ustrip.(z),
		ustrip.([magnetic_flux_density(loop, 0u"m", 0u"m", z)[3] for z in z]) ./ 1e-4,
		marker=:circle,
		legend=:false
	)
	xlabel!("z (mm)")
	ylabel!("Bz (Gauss/A)")
end

# ╔═╡ 4aa77f2e-518f-43b7-8db3-e4d0d790bf26
let
	ρ = range(-100u"mm", 100u"mm", 101)

	plot(
		ustrip.(ρ),
		ustrip.([magnetic_flux_density(loop, ρ, 0u"m", 0u"m")[3] for ρ in ρ]) ./ 1e-4,
		marker=:circle,
		legend=:false
	)
	xlabel!("ρ (mm)")
	ylabel!("Bz (Gauss/A)")
end

# ╔═╡ d00c68f5-0efc-43e4-ab65-45383e51ed1b
md"## Two equal loops"

# ╔═╡ 0b58a74b-1a53-4462-afd0-e3a2018966b0
loops2 = Helmholtz(loop, distance=20u"mm")

# ╔═╡ 7f470d0d-a808-4a48-81a2-247b2a8b9628
let
	z = range(-100u"mm", 100u"mm", 50)

	plot(
		ustrip.(z),
		ustrip.([
			[magnetic_flux_density(loops2.coils[1], 0u"m", 0u"m", z)[3] for z in z],
			[magnetic_flux_density(loops2.coils[2], 0u"m", 0u"m", z)[3] for z in z],
			[magnetic_flux_density(loops2, 0u"m", 0u"m", z)[3] for z in z],
		]) ./ 1e-4,
		marker=[:circle :star :cross],
		labels=["Top", "Bottom", "Sum"],
		legend=:false
	)
	xlabel!("z (mm)")
	ylabel!("Bz (Gauss/A)")
end

# ╔═╡ 64a19d40-e547-40f4-b1f6-1f995c51eadc
let
	ρ = range(-100u"mm", 100u"mm", 50)

	plot(
		ustrip.(ρ),
		ustrip.([
			[magnetic_flux_density(loops2.coils[1], ρ, 0u"m", 0u"m")[3] for ρ in ρ],
			[magnetic_flux_density(loops2.coils[2], ρ, 0u"m", 0u"m")[3] for ρ in ρ],
			[magnetic_flux_density(loops2, ρ, 0u"m", 0u"m")[3] for ρ in ρ],
		]) ./ 1e-4,
		marker=[:circle :star :cross],
		labels=["Top", "Bottom", "Sum"],
		legend=:false
	)
	xlabel!("ρ (mm)")
	ylabel!("Bz (Gauss/A)")
end

# ╔═╡ Cell order:
# ╟─b6d76845-3a1d-4942-bc23-953314c175c7
# ╟─0a823f86-84ce-11ef-3769-85b3a340da52
# ╟─5ada996f-8938-4a8a-92e6-98addd151079
# ╟─f57cb21c-ad20-4965-87a0-6d750913e5cf
# ╠═3c6d5660-30d5-4cda-b7bc-44c4a5c4b93e
# ╠═56ce9aef-4b7f-4790-9cea-85a9ae1e5068
# ╟─4aa77f2e-518f-43b7-8db3-e4d0d790bf26
# ╟─d00c68f5-0efc-43e4-ab65-45383e51ed1b
# ╟─0b58a74b-1a53-4462-afd0-e3a2018966b0
# ╟─7f470d0d-a808-4a48-81a2-247b2a8b9628
# ╟─64a19d40-e547-40f4-b1f6-1f995c51eadc
