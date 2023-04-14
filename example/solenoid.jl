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
# Solenoid coil

The present notebook visualizes the magnetic flux density created by a solenoid coil.
"""

# ╔═╡ a721bc22-5a61-4696-900a-3140b226211a
md"Current: $(@bind current_A NumberField(1:100, default=1000)) A"

# ╔═╡ 41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
md"Radius: $(@bind radius_mm NumberField(1:100, default=4)) mm"

# ╔═╡ d454927c-6efc-48d4-85b2-b0669ab879f1
md"Length: $(@bind length_mm NumberField(1:100, default=10)) mm"

# ╔═╡ e8183ea2-e78b-47e7-b55e-973584a53f0f
md"Number of turns: $(@bind turns_int NumberField(1:10, default=24))"

# ╔═╡ e69c1cf6-c28c-4a49-800b-436dfeb76b89
begin
	current = current_A * 1u"A"
	radius = radius_mm * 1u"mm"
	length = length_mm * 1u"mm"

	turns = UInt8(turns_int)
end;

# ╔═╡ 763f9094-8983-4096-b68d-5a6e4a191459
coil = Solenoid(current=current, radius=radius, length=length, turns=turns)

# ╔═╡ c3ab7f86-bf3b-4a35-b236-764ee8fba05b
ρ = LinRange(0.0u"mm", 1.2radius, 100);

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
    	title="Radial component (G)",
    	xlabel="Radial coordinate ρ (m)",
    	ylabel="Axial coordinate z (m)",
  	)	

  	p2 = heatmap(ρ, z, map(B -> B[2], B),
	    c=:viridis,
	    title="Axial component (G)",
	    xlabel="Radial coordinate ρ (m)",
	    ylabel="Axial coordinate z (m)",
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
# ╠═a721bc22-5a61-4696-900a-3140b226211a
# ╟─41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
# ╟─d454927c-6efc-48d4-85b2-b0669ab879f1
# ╟─e8183ea2-e78b-47e7-b55e-973584a53f0f
# ╟─e69c1cf6-c28c-4a49-800b-436dfeb76b89
# ╠═763f9094-8983-4096-b68d-5a6e4a191459
# ╠═c3ab7f86-bf3b-4a35-b236-764ee8fba05b
# ╠═06ae6131-f183-4594-85ac-ecc8663b8b7d
# ╟─628c0e45-c0f9-40ab-bf20-39ee56003865
# ╟─6ab67973-2e3a-4a45-93cf-c027d55ffccc
