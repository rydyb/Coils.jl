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

# ╔═╡ c94bc61a-6d24-4292-b796-a1b801752ba0
begin
	using Pkg

	Pkg.add(url="https://github.com/ryd-yb/Coils.jl#main")
end

# ╔═╡ fc5fe978-dd7c-47f0-ad16-d11fbeff66c1
using Coils, Plots, PlutoUI

# ╔═╡ b198599a-6bae-4b7c-a4f7-72f29966d54e
md"""
# Current loop

The present notebook visualizes the magnetic flux density created by a current loop.
"""

# ╔═╡ 1a611c41-9edb-434a-a3aa-398e89e75b02
md"Current $(@bind current NumberField(1:100)) A"

# ╔═╡ 4458a7e9-0a7f-4f52-8064-09bf4c883a86
md"Radius $(@bind radius NumberField(0.1:10, default=1)) m"

# ╔═╡ 387259d6-a752-4a4d-8f19-ac7a97c6961e
let
	cl = CurrentLoop(current, radius)
	
	ρ = LinRange(0.0, 1.5radius, 100)
	z = LinRange(-radius, radius, 100)
	
	B_axial = reduce(vcat, mfd.(Ref(cl), 0.0, z)) ./ 1e-4
	B_radial = reduce(vcat, mfd.(Ref(cl), ρ, 0.0)) ./ 1e-4
	
	p1 = plot(z, B_axial,
		seriestype=:scatter,
		markers=[:circle :hex],
		labels=["Bρ" "Bz"],
		title="Axial ρ=0",
		xlabel="Axial coordinate z (m)",
		ylabel="Magnetic flux density B (G)",
	)
	p2 =plot(ρ, B_radial,
		seriestype=:scatter,
		markers=[:circle :hex],
		labels=["Bρ" "Bz"],
		title="Radial z=0",
		xlabel="Radial coordinate ρ (m)",
		ylabel="Magnetic flux density B (G)",
	)

	ρz = wires(cl)
	vline!(p2, ρi[:, 1], label="")
	vline!(p1, zi[:, 2], label="")

	plot(p1, p2)
end

# ╔═╡ Cell order:
# ╠═c94bc61a-6d24-4292-b796-a1b801752ba0
# ╠═fc5fe978-dd7c-47f0-ad16-d11fbeff66c1
# ╟─b198599a-6bae-4b7c-a4f7-72f29966d54e
# ╟─1a611c41-9edb-434a-a3aa-398e89e75b02
# ╟─4458a7e9-0a7f-4f52-8064-09bf4c883a86
# ╠═387259d6-a752-4a4d-8f19-ac7a97c6961e
