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
using Revise, Coils, Plots, PlutoUI

# ╔═╡ 1c31570d-12a1-4e6e-bc94-0a27f87bd54a
md"""
# Solenoid

The present notebook visualizes the magnetic flux density created by a solenoid.
"""

# ╔═╡ a721bc22-5a61-4696-900a-3140b226211a
md"Current: $(@bind current NumberField(1:100, default=100)) A"

# ╔═╡ 41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
md"Inner radius: $(@bind inner_radius NumberField(0.01:10, default=0.1)) m"

# ╔═╡ e8183ea2-e78b-47e7-b55e-973584a53f0f
md"Number of axial turns: $(@bind axial_turns NumberField(1:10, default=6))"

# ╔═╡ 134dbae0-b1ae-42a9-b54c-d3e8efab6052
md"Number of radial turns: $(@bind radial_turns NumberField(1:10, default=2))"

# ╔═╡ 23f443e0-69bd-41c8-9a49-1009c341bdd8
md"Axial spacing: $(@bind axial_spacing NumberField(1e-3:10e-3)) m"

# ╔═╡ 21845573-cecd-4cff-88b7-d2cb5d03ba1d
md"Radial spacing: $(@bind radial_spacing NumberField(1e-3:10e-3)) m"

# ╔═╡ 763f9094-8983-4096-b68d-5a6e4a191459
solenoid = Solenoid(current, inner_radius, axial_turns, axial_spacing, radial_turns, radial_spacing)

# ╔═╡ c3ab7f86-bf3b-4a35-b236-764ee8fba05b
ρ = LinRange(0.0, 1.5inner_radius, 100);

# ╔═╡ 06ae6131-f183-4594-85ac-ecc8663b8b7d
z = LinRange(-axial_turns * axial_spacing, axial_turns * axial_spacing, 100);

# ╔═╡ 628c0e45-c0f9-40ab-bf20-39ee56003865
let
  B_axial = reduce(vcat, mfd.(Ref(solenoid), 0.0, z))
  B_radial = reduce(vcat, mfd.(Ref(solenoid), ρ, 0.0))

  p1 = plot(z, B_axial,
    seriestype=:scatter,
    markers=[:circle :hex],
    labels=["Bρ" "Bz"],
    title="Axial ρ=0",
    xlabel="Axial coordinate z (m)",
    ylabel="Magnetic flux density B (G)",
  )
  p2 = plot(ρ, B_radial,
    seriestype=:scatter,
    markers=[:circle :hex],
    labels=["Bρ" "Bz"],
    title="Radial z=0",
    xlabel="Radial coordinate ρ (m)",
    ylabel="Magnetic flux density B (G)",
  )

  ρz = reduce(vcat, wires(solenoid))
  vline!(p2, ρz[:, 1], label="")
  vline!(p1, ρz[:, 2], label="")

  plot(p1, p2)
end

# ╔═╡ 6ab67973-2e3a-4a45-93cf-c027d55ffccc
let
  B = [mfd(solenoid, ρi, zi) for zi in z, ρi in ρ]
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

  ρz = reduce(vcat, wires(solenoid))
  scatter!(p1, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)
  scatter!(p2, ρz[:, 1], ρz[:, 2], markershape=:circle, legend=false)

  plot(p1, p2, plot_title="Magnetic flux density")
end

# ╔═╡ Cell order:
# ╠═140dfe30-b11e-11ed-2cb0-f5987396b78b
# ╠═1f3f019c-6991-480e-b74a-f632a9f874b9
# ╟─1c31570d-12a1-4e6e-bc94-0a27f87bd54a
# ╟─a721bc22-5a61-4696-900a-3140b226211a
# ╠═41f28788-2e4f-4d42-8ca4-2cd29ad0b88f
# ╟─e8183ea2-e78b-47e7-b55e-973584a53f0f
# ╟─134dbae0-b1ae-42a9-b54c-d3e8efab6052
# ╟─23f443e0-69bd-41c8-9a49-1009c341bdd8
# ╟─21845573-cecd-4cff-88b7-d2cb5d03ba1d
# ╠═763f9094-8983-4096-b68d-5a6e4a191459
# ╠═c3ab7f86-bf3b-4a35-b236-764ee8fba05b
# ╠═06ae6131-f183-4594-85ac-ecc8663b8b7d
# ╟─628c0e45-c0f9-40ab-bf20-39ee56003865
# ╟─6ab67973-2e3a-4a45-93cf-c027d55ffccc
