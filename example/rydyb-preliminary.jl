### A Pluto.jl notebook ###
# v0.20.0

using Markdown
using InteractiveUtils

# ╔═╡ 6e0eefe8-84bc-11ef-3034-83d7fa963949
begin
	import Pkg
	Pkg.activate(".")
end

# ╔═╡ 2f64e4f8-b1bb-4821-89d4-ee55f7535a1f
begin
	using Coils
	using DynamicQuantities
	using LinearAlgebra
	using Plots
end

# ╔═╡ 3d29050a-9a4f-47e9-985c-325343f85cf2
md"# Preliminary MOT coils"

# ╔═╡ e07c2240-4cad-4ad9-a23e-858513676811
mfd(coil, x, y, z) = norm(magnetic_flux_density(coil, x, y, z))

# ╔═╡ 74cb430a-d011-4c8f-92e2-62a6150ce9ba
mfdmax(coil) = norm(magnetic_flux_density(coil, 0u"m", 0u"m", 0u"m"))

# ╔═╡ cc6763ca-837b-4074-b8bc-c79e16864f43
mfdinhomo(coil) = norm(magnetic_flux_density(coil, 1u"mm"+fov/2, 1u"mm"+fov/2, 0u"m") .- magnetic_flux_density(coil, 1u"mm", 1u"mm", 0u"m"))

# ╔═╡ c140ed6e-ec0f-46f1-8b59-aa11d929bf4b
md"## Parameters"

# ╔═╡ 9811ae08-181a-42d7-9f71-9920e68aa0b5
inner_diameter = 38u"mm"

# ╔═╡ 94d761bc-8808-4879-b0c9-1fefda24d6ef
outer_diameter = 55u"mm"

# ╔═╡ 885caaaa-e950-465a-8bd5-e156f13c1433
radial_turns = 6

# ╔═╡ c2e12354-bb5f-4f8b-b454-0ec589c0a059
axial_turns = 4

# ╔═╡ 83942330-a0ff-44b7-abef-5e7f32bb610d
thickness = 6.6u"mm"

# ╔═╡ 160d953d-87cd-4c12-af30-b03ef55aa3b6
md"## Model"

# ╔═╡ 77dda809-f7b9-4737-8926-29b3e460efc6
coil = CircularCoil(
	current=10u"A",
	radial_turns=radial_turns,
	axial_turns=axial_turns,
	inner_diameter=inner_diameter,
	outer_diameter=outer_diameter,
	thickness=thickness,
)

# ╔═╡ 6949d82b-55ce-4d88-b80e-5331a1af5af4
let

	ρ = []
	z = []
	
	for coil in coil.coils
		push!(ρ, ustrip(coil.coil.diameter)/2 / 1e-3)
		push!(z, ustrip(coil.z) / 1e-3)
	end

	scatter(ρ, z, legend=:false)
	title!("Conductor position")
	xlims!(0, 30)
	ylims!(-10, 10)
	xlabel!("Radial coordinate ρ (mm)")
	ylabel!("Axial coordinate z (mm)")
end

# ╔═╡ 5c9a9bdf-b273-45ce-8c4b-973ba82be771
md"### Homogeneous"

# ╔═╡ 8daf19c0-35f7-403e-8f24-dc1bfc8314b2
let
	d = range(10u"mm", 100u"mm", 51)
	
	plot(
		ustrip.(d) ./ 1e-3,
		ustrip.([mfd(Helmholtz(coil, distance=d), 0u"m", 0u"m", 0u"m") for d in d]) ./ 1e-4,
		markershape=:circle,
		legend=:false
	)
	xlabel!("d (mm)")
	ylabel!("Bz (Gauss/A)")
end

# ╔═╡ 1522e21c-dbb3-4f38-9c4f-63955da4d373
[(d, mfd(Helmholtz(coil, distance=d), 0u"m", 0u"m", 0u"m") ./ 1e-4) for d in range(60u"mm", 100u"mm", 20)]

# ╔═╡ 0f0704dd-5e4b-4720-a1d7-5aeee1792616
md"### Gradient"

# ╔═╡ 49041b70-4b7a-4344-90af-43f76f942e85
let
	d = range(10u"mm", 100u"mm", 51)
	
	plot(
		ustrip.(d) ./ 1e-3,
		ustrip.([(-mfd(AntiHelmholtz(coil, distance=d), 0u"m", 0u"m", 5u"mm")+mfd(Helmholtz(coil, distance=d), 0u"m", 0u"m", -5u"mm"))/2 for d in d]) ./ 1e-4,
		markershape=:circle,
		legend=:false
	)
	xlabel!("d (mm)")
	ylabel!("Bz (Gauss/A/mm)")
end

# ╔═╡ Cell order:
# ╟─3d29050a-9a4f-47e9-985c-325343f85cf2
# ╟─6e0eefe8-84bc-11ef-3034-83d7fa963949
# ╟─2f64e4f8-b1bb-4821-89d4-ee55f7535a1f
# ╟─e07c2240-4cad-4ad9-a23e-858513676811
# ╠═74cb430a-d011-4c8f-92e2-62a6150ce9ba
# ╠═cc6763ca-837b-4074-b8bc-c79e16864f43
# ╟─c140ed6e-ec0f-46f1-8b59-aa11d929bf4b
# ╟─9811ae08-181a-42d7-9f71-9920e68aa0b5
# ╟─94d761bc-8808-4879-b0c9-1fefda24d6ef
# ╟─885caaaa-e950-465a-8bd5-e156f13c1433
# ╟─c2e12354-bb5f-4f8b-b454-0ec589c0a059
# ╟─83942330-a0ff-44b7-abef-5e7f32bb610d
# ╟─160d953d-87cd-4c12-af30-b03ef55aa3b6
# ╠═77dda809-f7b9-4737-8926-29b3e460efc6
# ╠═6949d82b-55ce-4d88-b80e-5331a1af5af4
# ╟─5c9a9bdf-b273-45ce-8c4b-973ba82be771
# ╟─8daf19c0-35f7-403e-8f24-dc1bfc8314b2
# ╟─1522e21c-dbb3-4f38-9c4f-63955da4d373
# ╟─0f0704dd-5e4b-4720-a1d7-5aeee1792616
# ╟─49041b70-4b7a-4344-90af-43f76f942e85
