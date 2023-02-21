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

	Pkg.activate("..")
end

# ╔═╡ d5e4c4f6-7b9f-483b-b517-45ecfa59930c
using Revise, Coils, Plots, PlutoUI

# ╔═╡ 0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
md"""
# Helmholtz

The present notebook visualizes the magnetic flux density created by a Helmholtz coil.
"""

# ╔═╡ 0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
md"Current: $(@bind current NumberField(1:300, default=100)) A"

# ╔═╡ a5780f99-cce4-4ecb-9b92-80825a36780c
md"Inner radius $(@bind inner_radius_mm NumberField(1:100, default=30)) mm"

# ╔═╡ a4b8fc31-c021-4acd-8857-8e30095f359b
md"Number of radial turns: $(@bind radial_turns NumberField(1:12, default=6))"

# ╔═╡ 42e2bc75-4aa5-4a70-b792-133c673cbe2a
md"Radial spacing: $(@bind radial_spacing_mm NumberField(0.1:0.1:2.0, default=0.2)) mm"

# ╔═╡ 0b4c5b72-8172-44c7-bd62-9c8dab2e31b1
begin
	inner_radius = 1e-3inner_radius_mm
	radial_spacing = 1e-3radial_spacing_mm

	outer_radius = inner_radius + radial_turns * radial_spacing
	effective_radius = (inner_radius + outer_radius) / 2
end;

# ╔═╡ 8b9e5714-0d45-45a9-8e51-4d9c4a00a0a8
begin
	using Unitful
	using PhysicalConstants.CODATA2018: μ_0

	μ₀ = ustrip(u"N/A^2", μ_0)

	magnetic_flux_density = (8μ₀ / √125) * radial_turns * current / effective_radius / 1e-4;
end

# ╔═╡ 5b592441-c5ed-4f1e-9edd-41726c61638c
md"""
[The magnetic flux density between the Helmholtz coil is](https://de.wikipedia.org/wiki/Helmholtz-Spule)

$$\boldsymbol{B}(0,0)=
\frac{8\mu_0}{\sqrt{125}}\frac{NI}{R_\text{eff}}
,$$

wherein $N$ is the number of total turns and $R_\text{eff}$ is the effective radius.
"""

# ╔═╡ 04751d13-3cf2-485b-9c8c-7d09ff38f38e
solenoid = Solenoid(current, inner_radius, 2, 1e-3, radial_turns, radial_spacing)

# ╔═╡ f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
helmholtz = Helmholtz(solenoid, effective_radius)

# ╔═╡ 94981d0a-26a8-410e-9aec-06f773fc41a3
begin
	z = LinRange(-1.2inner_radius, 1.2inner_radius, 100);
	ρ = LinRange(0, 1.2outer_radius, 100)
end;

# ╔═╡ 94ab23e3-b77d-434f-9f6d-22c13e9dfc06
let
	B = [mfd(helmholtz, ρi, zi) for zi in z, ρi in ρ]
	Bρ = map(B -> B[1], B)
	Bz = map(B -> B[2], B)

	p1 = heatmap(ρ, z, Bρ,
		c=:viridis,
		transpose=1,
		title="Radial component (G)",
		xlabel="Radial coordinate ρ (m)",
		ylabel="Axial coordinate z (m)",
	)

	p2 = heatmap(ρ, z, Bz,
		c=:viridis,
		title="Axial component (G)",
		xlabel="Radial coordinate ρ (m)",
		ylabel="Axial coordinate z (m)",
	)

	ρz = reduce(vcat, wires(helmholtz))
	scatter!(p1, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
	scatter!(p2, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
	
	plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ 9968823b-4397-4379-a174-66e53b279ff1
let
	B = reduce(vcat, mfd.(Ref(helmholtz), 0.0, z))

	plot(z, B,
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Axial ρ=0",
    	xlabel="Axial coordinate z (m)",
    	ylabel="Magnetic flux density B (G)",
  	)

	hline!(z, [magnetic_flux_density], color="black", linewidth=2)
end

# ╔═╡ Cell order:
# ╠═ae9a85d0-b0f2-11ed-161e-f355a5ee436b
# ╠═d5e4c4f6-7b9f-483b-b517-45ecfa59930c
# ╟─0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
# ╟─0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
# ╟─a5780f99-cce4-4ecb-9b92-80825a36780c
# ╟─a4b8fc31-c021-4acd-8857-8e30095f359b
# ╟─42e2bc75-4aa5-4a70-b792-133c673cbe2a
# ╟─0b4c5b72-8172-44c7-bd62-9c8dab2e31b1
# ╟─5b592441-c5ed-4f1e-9edd-41726c61638c
# ╟─8b9e5714-0d45-45a9-8e51-4d9c4a00a0a8
# ╠═04751d13-3cf2-485b-9c8c-7d09ff38f38e
# ╠═f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
# ╠═94981d0a-26a8-410e-9aec-06f773fc41a3
# ╟─94ab23e3-b77d-434f-9f6d-22c13e9dfc06
# ╠═9968823b-4397-4379-a174-66e53b279ff1
