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
md"Inner radius $(@bind inner_radius_mm NumberField(1:100, default=10)) mm"

# ╔═╡ a4b8fc31-c021-4acd-8857-8e30095f359b
md"Number of radial turns: $(@bind radial_turns NumberField(1:12, default=6))"

# ╔═╡ 42e2bc75-4aa5-4a70-b792-133c673cbe2a
md"Radial spacing: $(@bind radial_spacing_mm NumberField(0.1:1.0, default=0.1)) mm"

# ╔═╡ 04751d13-3cf2-485b-9c8c-7d09ff38f38e
solenoid = Solenoid(current, 1e-3inner_radius_mm, 1, 0.0, 1e-3radial_spacing_mm, radial_turns)

# ╔═╡ f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
helmholtz = Superposition([AxialOffset(solenoid)])

# ╔═╡ Cell order:
# ╠═ae9a85d0-b0f2-11ed-161e-f355a5ee436b
# ╠═d5e4c4f6-7b9f-483b-b517-45ecfa59930c
# ╟─0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
# ╟─0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
# ╟─a5780f99-cce4-4ecb-9b92-80825a36780c
# ╟─a4b8fc31-c021-4acd-8857-8e30095f359b
# ╟─42e2bc75-4aa5-4a70-b792-133c673cbe2a
# ╠═04751d13-3cf2-485b-9c8c-7d09ff38f38e
# ╠═f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
