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

# ╔═╡ 711c8c44-3f8a-4b40-9e9f-6350c203b750
current = current_A * 1u"A"

# ╔═╡ 41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
md"Inner radius: $(@bind inner_radius_mm NumberField(1:100, default=10)) mm"

# ╔═╡ 82474318-f0aa-437f-875c-0eb76350f80a
inner_radius = inner_radius_mm * 1u"mm"

# ╔═╡ d454927c-6efc-48d4-85b2-b0669ab879f1
md"Outer radius: $(@bind outer_radius_mm NumberField(1:100, default=12)) mm"

# ╔═╡ 75d13959-6c41-4c7a-859e-e66dadefb79f
outer_radius = outer_radius_mm * 1u"mm"

# ╔═╡ d85dfec3-e5cb-40c9-afa6-3d43e1af92f6
md"Length: $(@bind length_mm NumberField(1:100, default=20)) mm"

# ╔═╡ 39cb20d4-dcbe-483a-b8f5-84c38164c751
length = length_mm * 1u"mm"

# ╔═╡ e8183ea2-e78b-47e7-b55e-973584a53f0f
md"Number of axial turns: $(@bind axial_turns_int NumberField(1:10, default=6))"

# ╔═╡ 8cde15b5-edd1-4325-8396-276ef060dc43
axial_turns = UInt8(axial_turns_int)

# ╔═╡ 134dbae0-b1ae-42a9-b54c-d3e8efab6052
md"Number of radial turns: $(@bind radial_turns_int NumberField(1:10, default=2))"

# ╔═╡ e69c1cf6-c28c-4a49-800b-436dfeb76b89
radial_turns = UInt8(radial_turns_int)

# ╔═╡ 763f9094-8983-4096-b68d-5a6e4a191459
helical = Helical(
	current=current,
	inner_radius=inner_radius,
	outer_radius=outer_radius,
	length=length,
	axial_turns=axial_turns,
	radial_turns=radial_turns,
)

# ╔═╡ 39412042-a4a9-466d-891e-06d085f6bb82
current_loops = CurrentLoops(helical)

# ╔═╡ 6b74155f-7de4-4802-be06-b5b64be40c80
let
	ρ = LinRange(0u"mm", 1.2outer_radius, 100)
	z = 0.0u"m"
	
	plot(ρ, hcat(mfd.(Ref(current_loops), ρ, z)...)',
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Radial z=0",
    	xlabel="Radial coordinate ρ",
    	ylabel="Magnetic flux density B",
  	)

	vline!(map(x -> x[1], conductor_coordinates(current_loops)), label="")
end

# ╔═╡ bcafcc61-1e7c-45cb-aaa1-b944f8b95519
let
	ρ = 0.0u"m"
	z = LinRange(-1.2length, 1.2length, 100)
	
	plot(z, hcat(mfd.(Ref(current_loops), ρ, z)...)',
		seriestype=:scatter,
		markers=[:circle :hex],
		labels=["Bρ" "Bz"],
		title="Axial ρ=0",
		xlabel="Axial coordinate z",
		ylabel="Magnetic flux density B",
  	)

	try
		hline!(mfdz(helical))
	catch y
    	print(y)
	end

	vline!(map(x -> x[2], conductor_coordinates(current_loops)), label="")
end

# ╔═╡ 6ab67973-2e3a-4a45-93cf-c027d55ffccc
let
	ρ = LinRange(0u"mm", 1.2outer_radius, 100)
	z = LinRange(-1.2length, 1.2length, 100)

	B = reshape([mfd(current_loops, ρ, z) for ρ in ρ for z in z], 100, 100)

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

  	cc = conductor_coordinates(current_loops)
  	scatter!(p1, cc, markershape=:circle, legend=false)
  	scatter!(p2, cc, markershape=:circle, legend=false)

  	plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ Cell order:
# ╠═140dfe30-b11e-11ed-2cb0-f5987396b78b
# ╠═1f3f019c-6991-480e-b74a-f632a9f874b9
# ╟─1c31570d-12a1-4e6e-bc94-0a27f87bd54a
# ╟─a721bc22-5a61-4696-900a-3140b226211a
# ╟─711c8c44-3f8a-4b40-9e9f-6350c203b750
# ╟─41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
# ╟─82474318-f0aa-437f-875c-0eb76350f80a
# ╟─d454927c-6efc-48d4-85b2-b0669ab879f1
# ╟─75d13959-6c41-4c7a-859e-e66dadefb79f
# ╟─d85dfec3-e5cb-40c9-afa6-3d43e1af92f6
# ╟─39cb20d4-dcbe-483a-b8f5-84c38164c751
# ╟─e8183ea2-e78b-47e7-b55e-973584a53f0f
# ╟─8cde15b5-edd1-4325-8396-276ef060dc43
# ╟─134dbae0-b1ae-42a9-b54c-d3e8efab6052
# ╟─e69c1cf6-c28c-4a49-800b-436dfeb76b89
# ╟─763f9094-8983-4096-b68d-5a6e4a191459
# ╟─39412042-a4a9-466d-891e-06d085f6bb82
# ╟─6b74155f-7de4-4802-be06-b5b64be40c80
# ╟─bcafcc61-1e7c-45cb-aaa1-b944f8b95519
# ╟─6ab67973-2e3a-4a45-93cf-c027d55ffccc
