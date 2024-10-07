### A Pluto.jl notebook ###
# v0.19.46

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

# ╔═╡ 59d09a26-36dc-42b6-8874-cfe7abb85d73
function circular_loops(; current, radial_turns, axial_turns, inner_diameter, outer_diameter, height)
	# radial and axial offset
	ρ₀ = inner_diameter / 2
	z₀ = -height / 2
	
	# radial and axial spacing
	Δρ = (outer_diameter - inner_diameter) / (2 * radial_turns)
	Δz = height / axial_turns
	
	# superimpose the circular current loops
	loops = Vector{AbstractCoil}()
	for i in 1:radial_turns
		loop = CircularLoop(current=current, radius=ρ₀ + Δρ * i)

		for j in 1:axial_turns
			dloop = Displace(loop; z = z₀ + Δz * j)
			
			push!(loops, dloop)
		end
	end

	return Superposition(loops)
end

# ╔═╡ e07c2240-4cad-4ad9-a23e-858513676811
mfd(coil, x, y, z) = norm(magnetic_flux_density(coil, x, y, z))

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

# ╔═╡ 160d953d-87cd-4c12-af30-b03ef55aa3b6
md"## Model"

# ╔═╡ 77dda809-f7b9-4737-8926-29b3e460efc6
coil = circular_loops(current=1u"A", radial_turns=radial_turns, axial_turns=axial_turns, inner_diameter=inner_diameter, outer_diameter=outer_diameter, height=6.6u"mm")

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

# ╔═╡ 0f0704dd-5e4b-4720-a1d7-5aeee1792616
md"### Gradient"

# ╔═╡ 49041b70-4b7a-4344-90af-43f76f942e85
let
	d = range(10u"mm", 100u"mm", 51)
	
	plot(
		ustrip.(d) ./ 1e-3,
		ustrip.([(mfd(Helmholtz(coil, distance=d), 0u"m", 0u"m", 1u"mm")-mfd(Helmholtz(coil, distance=d), 0u"m", 0u"m", -1u"mm"))/2 for d in d]) ./ 1e-4,
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
# ╟─59d09a26-36dc-42b6-8874-cfe7abb85d73
# ╟─e07c2240-4cad-4ad9-a23e-858513676811
# ╟─c140ed6e-ec0f-46f1-8b59-aa11d929bf4b
# ╟─9811ae08-181a-42d7-9f71-9920e68aa0b5
# ╟─94d761bc-8808-4879-b0c9-1fefda24d6ef
# ╟─885caaaa-e950-465a-8bd5-e156f13c1433
# ╟─c2e12354-bb5f-4f8b-b454-0ec589c0a059
# ╟─160d953d-87cd-4c12-af30-b03ef55aa3b6
# ╟─77dda809-f7b9-4737-8926-29b3e460efc6
# ╟─5c9a9bdf-b273-45ce-8c4b-973ba82be771
# ╟─8daf19c0-35f7-403e-8f24-dc1bfc8314b2
# ╟─0f0704dd-5e4b-4720-a1d7-5aeee1792616
# ╟─49041b70-4b7a-4344-90af-43f76f942e85
