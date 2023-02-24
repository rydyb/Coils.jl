### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ae9a85d0-b0f2-11ed-161e-f355a5ee436b
begin
	using Pkg

	Pkg.activate(".")
end

# ╔═╡ d5e4c4f6-7b9f-483b-b517-45ecfa59930c
using Revise, Unitful, Coils, Plots, PlutoUI

# ╔═╡ 0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
md"""
# Helmholtz

The present notebook visualizes the magnetic flux density created by a Helmholtz coil.
"""

# ╔═╡ 0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
md"Current: $(@bind current_A NumberField(1:300, default=100)) A"

# ╔═╡ a5780f99-cce4-4ecb-9b92-80825a36780c
md"Inner radius $(@bind inner_radius_mm NumberField(1:100, default=30)) mm"

# ╔═╡ a5556fc2-9f5e-41c8-81b5-01678d78e9a3
md"Outer radius $(@bind outer_radius_mm NumberField(1:100, default=40)) mm"

# ╔═╡ ffe05385-89ee-4f4c-b3a4-8e9ce180316c
md"Length $(@bind length_mm NumberField(1:100, default=10)) mm"

# ╔═╡ b2544144-04ad-4c2e-a292-e0657122545e
md"Number of axial turns $(@bind axial_turns_int NumberField(2:2:10, default=4))"

# ╔═╡ a4b8fc31-c021-4acd-8857-8e30095f359b
md"Number of radial turns: $(@bind radial_turns_int NumberField(1:12, default=6))"

# ╔═╡ 42e2bc75-4aa5-4a70-b792-133c673cbe2a
md"Separation: $(@bind separation_mm NumberField(1:40, default=20)) mm"

# ╔═╡ 0b4c5b72-8172-44c7-bd62-9c8dab2e31b1
begin
	current = current_A * 1u"A"
	inner_radius = inner_radius_mm * 1u"mm"
	outer_radius = outer_radius_mm * 1u"mm"
	effective_radius = (outer_radius + inner_radius) / 2
	length = length_mm * 1u"mm"
	separation = separation_mm * 1u"mm"

	axial_turns = UInt8(axial_turns_int)
	radial_turns = UInt8(radial_turns_int)
	total_turns = axial_turns * radial_turns
end;

# ╔═╡ f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
coil = Helmholtz(current, inner_radius, outer_radius, length, axial_turns, radial_turns, separation)

# ╔═╡ 94981d0a-26a8-410e-9aec-06f773fc41a3
z = LinRange(-1.2separation, 1.2separation, 100);

# ╔═╡ debd08c3-e572-4722-8af9-49a2d6da161d
ρ = LinRange(0u"mm", 1.2outer_radius, 100);

# ╔═╡ 94ab23e3-b77d-434f-9f6d-22c13e9dfc06
let
	B = [mfd(coil, ρi, zi) for zi in z, ρi in ρ]

	p1 = heatmap(ρ, z, map(B -> uconvert.(u"Gauss", B[1]), B),
		c=:viridis,
		transpose=1,
		title="Radial component",
		xlabel="Radial coordinate ρ",
		ylabel="Axial coordinate z",
	)
	p1

	p2 = heatmap(ρ, z, map(B -> uconvert.(u"Gauss", B[2]), B),
		c=:viridis,
		title="Axial component",
		xlabel="Radial coordinate ρ",
		ylabel="Axial coordinate z",
	)

	ρz = reduce(vcat, wires(coil))
	scatter!(p1, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
	scatter!(p2, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
	
	plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ 9968823b-4397-4379-a174-66e53b279ff1
let
	h = Helmholtz(current, inner_radius, outer_radius, length, axial_turns, radial_turns)

	B = reduce(vcat, mfd.(Ref(coil), 0u"mm", z))

	plot(z, [B reduce(vcat, mfd.(Ref(h), 0u"mm", z))],
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz" "Bρ (Helmholtz separation)" "Bz (Helmholtz separation)"],
    	title="Axial ρ=0",
    	xlabel="Axial coordinate z",
    	ylabel="Magnetic flux density B",
  	)

	hline!(z, [mfd_z(coil, 0u"m")[2]], color="black", linewidth=2, label="Bz (eq. (1))")
end

# ╔═╡ e46d04f9-aa32-40fd-88d4-55d1fcf3c8d2
md"""
where the black line denotes the approximation

$$B^z(0,0)=
\frac{8\mu_0}{\sqrt{125}}\frac{NI}{R_\text{eff}}
\tag{1}
,$$

wherein $N$ is the number of total turns and $R_\text{eff}$ is the effective radius.
"""

# ╔═╡ Cell order:
# ╠═ae9a85d0-b0f2-11ed-161e-f355a5ee436b
# ╠═d5e4c4f6-7b9f-483b-b517-45ecfa59930c
# ╟─0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
# ╟─0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
# ╟─a5780f99-cce4-4ecb-9b92-80825a36780c
# ╟─a5556fc2-9f5e-41c8-81b5-01678d78e9a3
# ╟─ffe05385-89ee-4f4c-b3a4-8e9ce180316c
# ╟─b2544144-04ad-4c2e-a292-e0657122545e
# ╟─a4b8fc31-c021-4acd-8857-8e30095f359b
# ╟─42e2bc75-4aa5-4a70-b792-133c673cbe2a
# ╟─0b4c5b72-8172-44c7-bd62-9c8dab2e31b1
# ╠═f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
# ╠═94981d0a-26a8-410e-9aec-06f773fc41a3
# ╠═debd08c3-e572-4722-8af9-49a2d6da161d
# ╟─94ab23e3-b77d-434f-9f6d-22c13e9dfc06
# ╟─9968823b-4397-4379-a174-66e53b279ff1
# ╟─e46d04f9-aa32-40fd-88d4-55d1fcf3c8d2
