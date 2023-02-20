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

	Pkg.activate("..")
end

# ╔═╡ fc5fe978-dd7c-47f0-ad16-d11fbeff66c1
using Coils, Plots, PlutoUI

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

To check our implementation, we visualize the components of the magnetic flux density.
"""

# ╔═╡ 1a611c41-9edb-434a-a3aa-398e89e75b02
md"Current $(@bind current NumberField(1:1000, default=100)) A"

# ╔═╡ 4458a7e9-0a7f-4f52-8064-09bf4c883a86
md"Radius $(@bind radius NumberField(0.1:10, default=1)) m"

# ╔═╡ 2a8d3d22-0bb1-4362-a1b6-6d92340a89c5
cl = CurrentLoop(current, radius);

# ╔═╡ 4d1a0f75-f9cc-4396-b5cc-1bb410eb5e4a
ρ = LinRange(0.0, 1.5radius, 100);

# ╔═╡ 2cccb15a-9e56-401a-8d12-f1afe986186a
z = LinRange(-radius, radius, 100);

# ╔═╡ 387259d6-a752-4a4d-8f19-ac7a97c6961e
let
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

	ρz = reduce(vcat, wires(cl))
	vline!(p2, ρz[:, 1], label="")
	vline!(p1, ρz[:, 2], label="")

	plot(p1, p2)
end

# ╔═╡ deab93a7-340c-404e-8a13-1d18e571104a
let
	B = [mfd(cl, ρi, zi) for zi in z, ρi in ρ] ./ 1e-4
	Bρ = map(B -> B[1], B)
	Bz = map(B -> B[2], B)

	p1 = heatmap(ρ, z, Bρ,
		c=:viridis,
		transpose=1,
		title="Radial component (G)",
		xlabel="Radial coordinate ρ (m)",
		ylabel="Axial coordinate z (m)",
	)

	p2 =heatmap(ρ, z, Bz,
		c=:viridis,
		title="Axial component (G)",
		xlabel="Radial coordinate ρ (m)",
		ylabel="Axial coordinate z (m)",
	)

	ρz = reduce(vcat, wires(cl))
	scatter!(p1, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
	scatter!(p2, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)

	plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ Cell order:
# ╟─c94bc61a-6d24-4292-b796-a1b801752ba0
# ╟─fc5fe978-dd7c-47f0-ad16-d11fbeff66c1
# ╟─b198599a-6bae-4b7c-a4f7-72f29966d54e
# ╟─9943a035-7183-4a48-a30e-c505cfb0cf4e
# ╟─1a611c41-9edb-434a-a3aa-398e89e75b02
# ╟─4458a7e9-0a7f-4f52-8064-09bf4c883a86
# ╟─2a8d3d22-0bb1-4362-a1b6-6d92340a89c5
# ╟─4d1a0f75-f9cc-4396-b5cc-1bb410eb5e4a
# ╟─2cccb15a-9e56-401a-8d12-f1afe986186a
# ╟─387259d6-a752-4a4d-8f19-ac7a97c6961e
# ╟─deab93a7-340c-404e-8a13-1d18e571104a
