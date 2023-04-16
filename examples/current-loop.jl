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
  Pkg.activate(".")
end

# ╔═╡ fc5fe978-dd7c-47f0-ad16-d11fbeff66c1
using Revise, Unitful, Coils, Plots, PlutoUI

# ╔═╡ b198599a-6bae-4b7c-a4f7-72f29966d54e
md"""
# Current loop

The present notebook visualizes the magnetic flux density created by a current loop.

## Theory

The exact solution to Biot-Savart's law of magnetism for a current loop is derived in Ref. [1,2], i.e.,

$$\begin{aligned}
B^\rho_\text{loop}
&=
\frac{C}{\alpha^2\beta}
\left\{
  \left(R^2+\rho^2+z^2\right)
  E(k^2)
  -
  \alpha^2K(k^2)
\right\}
\frac{z}{\rho}\\
B^z_\text{loop}
&=
\frac{C}{\alpha^2\beta}
\left\{
  \left(R^2-\rho^2-z^2\right)
  E(k^2)
  +
  \alpha^2K(k^2)
\right\}
\end{aligned}$$

wherein $C=\mu_0I/(2\pi)$,

$$\begin{aligned}
\alpha^2&=R^2+\rho^2+z^2-2R\rho\\
\beta^2&=R^2+\rho^2+z^2+2R\rho\\
\end{aligned},$$

and $k^2=1-\alpha^2/\beta^2$.
"""

# ╔═╡ 9943a035-7183-4a48-a30e-c505cfb0cf4e
md"""
## Simulation

To check our implementation, we visualize the components of the magnetic flux density and compare it with [the limiting case being on the radial axis](https://de.wikipedia.org/wiki/Leiterschleife), i.e.,

$$\boldsymbol{B}(\rho=0,z)
=
\frac{\mu_0 I}{2}
\frac{R^2}{\left(R^2+z^2\right)^{3/2}}
\boldsymbol{e}^z
.$$
"""

# ╔═╡ 1a611c41-9edb-434a-a3aa-398e89e75b02
md"Current $(@bind current_A NumberField(1:1000, default=1)) A"

# ╔═╡ e258400f-775a-41f3-a9ce-d97900679a5a
current = current_A * 1u"A"

# ╔═╡ 4458a7e9-0a7f-4f52-8064-09bf4c883a86
md"Radius $(@bind radius_mm NumberField(1:100, default=10)) mm"

# ╔═╡ 0f1e781e-5918-4651-b455-a2dee7bdd69b
radius = radius_mm * 1u"mm"

# ╔═╡ 88e92324-1060-4f52-8bf5-32f1d39aca9c
md"Height $(@bind height_mm NumberField(-50:50, default=0)) mm"

# ╔═╡ ee77604b-18bd-46ec-8619-aa260d42ac7d
height = height_mm * 1u"mm"

# ╔═╡ 2a8d3d22-0bb1-4362-a1b6-6d92340a89c5
current_loop = CurrentLoop(current=current, radius=radius, height=height)

# ╔═╡ 3a56b527-8afc-4d3e-a4f0-3470c520a530
let
	ρ = LinRange(0u"mm", 1.5radius, 100)
	z = 0.0u"m"
	
	plot(ρ, hcat(mfd.(Ref(current_loop), ρ, z)...)',
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Radial z=0",
    	xlabel="Radial coordinate ρ",
    	ylabel="Magnetic flux density B",
  	)

	vline!(map(x -> x[1], conductor_coordinates(current_loop)), label="")
end

# ╔═╡ f457852f-9574-4772-b623-debad2020a5e
let
	ρ = 0.0u"m"
	z = LinRange(-0.6radius, 0.6radius, 100)
	
	plot(z, hcat(mfd.(Ref(current_loop), ρ, z)...)',
		seriestype=:scatter,
		markers=[:circle :hex],
		labels=["Bρ" "Bz"],
		title="Axial ρ=0",
		xlabel="Axial coordinate z",
		ylabel="Magnetic flux density B",
  	)

	plot!(z, map(B -> B[2], mfdz.(Ref(current_loop), z)),
		label="",
		color="black",
		linewidth=2,
	)

	vline!(map(x -> x[2], conductor_coordinates(current_loop)), label="")
end

# ╔═╡ deab93a7-340c-404e-8a13-1d18e571104a
let
	ρ = LinRange(0u"mm", 1.5radius, 100)
	z = LinRange(-0.6radius, 0.6radius, 100)

	B = reshape([mfd(current_loop, ρ, z) for ρ in ρ for z in z], 100, 100)

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

  	cc = conductor_coordinates(current_loop)
  	scatter!(p1, cc, markershape=:circle, legend=false)
  	scatter!(p2, cc, markershape=:circle, legend=false)

  	plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ Cell order:
# ╠═c94bc61a-6d24-4292-b796-a1b801752ba0
# ╠═fc5fe978-dd7c-47f0-ad16-d11fbeff66c1
# ╟─b198599a-6bae-4b7c-a4f7-72f29966d54e
# ╟─9943a035-7183-4a48-a30e-c505cfb0cf4e
# ╟─1a611c41-9edb-434a-a3aa-398e89e75b02
# ╟─e258400f-775a-41f3-a9ce-d97900679a5a
# ╟─4458a7e9-0a7f-4f52-8064-09bf4c883a86
# ╟─0f1e781e-5918-4651-b455-a2dee7bdd69b
# ╟─88e92324-1060-4f52-8bf5-32f1d39aca9c
# ╟─ee77604b-18bd-46ec-8619-aa260d42ac7d
# ╟─2a8d3d22-0bb1-4362-a1b6-6d92340a89c5
# ╟─3a56b527-8afc-4d3e-a4f0-3470c520a530
# ╟─f457852f-9574-4772-b623-debad2020a5e
# ╟─deab93a7-340c-404e-8a13-1d18e571104a
