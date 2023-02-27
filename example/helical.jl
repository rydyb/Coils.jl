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

# ╔═╡ 140dfe30-b11e-11ed-2cb0-f5987396b78b
begin
  using Pkg

  Pkg.activate(".")
end

# ╔═╡ 1f3f019c-6991-480e-b74a-f632a9f874b9
using Revise, Unitful, Coils, Plots, PlutoUI

# ╔═╡ 1c31570d-12a1-4e6e-bc94-0a27f87bd54a
md"""
# Helical coil

The present notebook visualizes the magnetic flux density created by a helical coil.
"""

# ╔═╡ a721bc22-5a61-4696-900a-3140b226211a
md"Current: $(@bind current_A NumberField(1:100, default=100)) A"

# ╔═╡ 41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
md"Inner radius: $(@bind inner_radius_mm NumberField(1:100, default=10)) mm"

# ╔═╡ d454927c-6efc-48d4-85b2-b0669ab879f1
md"Outer radius: $(@bind outer_radius_mm NumberField(1:100, default=12)) mm"

# ╔═╡ d85dfec3-e5cb-40c9-afa6-3d43e1af92f6
md"Length: $(@bind length_mm NumberField(1:100, default=20)) mm"

# ╔═╡ e8183ea2-e78b-47e7-b55e-973584a53f0f
md"Number of axial turns: $(@bind axial_turns_int NumberField(1:10, default=6))"

# ╔═╡ 134dbae0-b1ae-42a9-b54c-d3e8efab6052
md"Number of radial turns: $(@bind radial_turns_int NumberField(1:10, default=2))"

# ╔═╡ e69c1cf6-c28c-4a49-800b-436dfeb76b89
begin
	current = current_A * 1u"A"
	inner_radius = inner_radius_mm * 1u"mm"
	outer_radius = outer_radius_mm * 1u"mm"
	length = length_mm * 1u"mm"

	axial_turns = UInt8(axial_turns_int)
	radial_turns = UInt8(radial_turns_int)
end;

# ╔═╡ 763f9094-8983-4096-b68d-5a6e4a191459
coil = Helical(current=current, inner_radius=inner_radius, outer_radius=outer_radius, length=length, axial_turns=axial_turns, radial_turns=radial_turns)

# ╔═╡ c3ab7f86-bf3b-4a35-b236-764ee8fba05b
ρ = LinRange(0u"mm", 1.2outer_radius, 100);

# ╔═╡ 06ae6131-f183-4594-85ac-ecc8663b8b7d
z = LinRange(-1.2length, 1.2length, 100);

# ╔═╡ 628c0e45-c0f9-40ab-bf20-39ee56003865
let
	p1 = plot(z, reduce(vcat, mfd.(Ref(coil), 0u"m", z)),
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Axial ρ=0",
    	xlabel="Axial coordinate z",
    	ylabel="Magnetic flux density B",
  	)
  	p2 = plot(ρ, reduce(vcat, mfd.(Ref(coil), ρ, 0u"m")),
	    seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Radial z=0",
	    xlabel="Radial coordinate ρ",
    	ylabel="Magnetic flux density B",
  	)

	ρz = reduce(vcat, conductor_coordinates(coil))
  	vline!(p2, ρz[:, 1], label="")
  	vline!(p1, ρz[:, 2], label="")

	plot(p1, p2)
end

# ╔═╡ 6ab67973-2e3a-4a45-93cf-c027d55ffccc
let
	B = [mfd(coil, ρ, z) for z in z, ρ in ρ]
	
	p1 = heatmap(ρ, z, map(B -> B[1], B),
    	c=:viridis,
    	transpose=1,
    	title="Radial component",
    	xlabel="Radial coordinate ρ",
    	ylabel="Axial coordinate z",
  	)	

  	p2 = heatmap(ρ, z, map(B -> B[2], B),
	    c=:viridis,
	    title="Axial component",
	    xlabel="Radial coordinate ρ",
	    ylabel="Axial coordinate z",
  	)

  	ρz = reduce(vcat, conductor_coordinates(coil))
  	scatter!(p1, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
  	scatter!(p2, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)

  	plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ Cell order:
# ╠═140dfe30-b11e-11ed-2cb0-f5987396b78b
# ╠═1f3f019c-6991-480e-b74a-f632a9f874b9
# ╟─1c31570d-12a1-4e6e-bc94-0a27f87bd54a
# ╟─a721bc22-5a61-4696-900a-3140b226211a
# ╟─41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
# ╟─d454927c-6efc-48d4-85b2-b0669ab879f1
# ╟─d85dfec3-e5cb-40c9-afa6-3d43e1af92f6
# ╟─e8183ea2-e78b-47e7-b55e-973584a53f0f
# ╟─134dbae0-b1ae-42a9-b54c-d3e8efab6052
# ╟─e69c1cf6-c28c-4a49-800b-436dfeb76b89
# ╠═763f9094-8983-4096-b68d-5a6e4a191459
# ╠═c3ab7f86-bf3b-4a35-b236-764ee8fba05b
# ╠═06ae6131-f183-4594-85ac-ecc8663b8b7d
# ╟─628c0e45-c0f9-40ab-bf20-39ee56003865
# ╟─6ab67973-2e3a-4a45-93cf-c027d55ffccc
