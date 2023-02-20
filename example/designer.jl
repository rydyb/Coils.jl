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
using Pkg, PlutoUI

# ╔═╡ d5e4c4f6-7b9f-483b-b517-45ecfa59930c
Pkg.develop(url="https://github.com/ryd-yb/Coils.jl")

# ╔═╡ 0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
md"""
# Designer

The present notebook illustrates how to design a coil with `Coils.jl`.
"""

# ╔═╡ 10d5d068-8284-4b8b-a3f0-f797bd7e95e6
md"""
## Constraints
"""

# ╔═╡ 61b7899e-e146-49ba-86ad-125f6ce4fb95
md"""
###### Atom area

The atom area is the subsection of the glass cell's midplane where we trap the atoms.
Aiming for a large atom area is favorable as it allows more atoms to trap, giving us more qubits.
However, the size of the atom area is effectively limited by the objective's field of view (FoV).

Field of view: $(@bind fov_um NumberField(10:400, default=160)) um
"""

# ╔═╡ 0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
md"""
###### Current

To switch between Helmholtz and anti-Helmholtz, we must reverse the current direction in one of the coils.
In the past, our switching circuits could switch up to 200 A, with updated components, we should be able to switch up to 300 A.

Current: $(@bind current NumberField(1:300, default=200)) A
"""

# ╔═╡ a5780f99-cce4-4ecb-9b92-80825a36780c
md"""
###### Inner coil diameter

The inner coil diameter refers to the free space between the coil windings.
For the main coils, the space needs to fit the objective, e.g.,

* our objective with a diameter of 47 mm, or
* SQM's objective with a diameter of 55 mm,

which may be translated by 4 mm.
Adding some additional margin, we fix the inner coil diameter

Inner coil diameter $(@bind inner_coil_diameter_mm NumberField(40:80, default=64)) mm
"""

# ╔═╡ a4b8fc31-c021-4acd-8857-8e30095f359b
md"""
###### Space between coils

The space between coils needs to fit the glass cell with a height of 32 mm and the coil mount. 

Space: $(@bind coil_space_mm NumberField(40:60, default=48)) mm
"""

# ╔═╡ 4ab8b6d7-7cef-4342-a277-1589e48b8271
md"""
## Comparison

Given these constraints, we are left to vary the number of radial and axial turns of the coils.
"""

# ╔═╡ Cell order:
# ╠═ae9a85d0-b0f2-11ed-161e-f355a5ee436b
# ╟─d5e4c4f6-7b9f-483b-b517-45ecfa59930c
# ╟─0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
# ╟─10d5d068-8284-4b8b-a3f0-f797bd7e95e6
# ╟─61b7899e-e146-49ba-86ad-125f6ce4fb95
# ╟─0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
# ╟─a5780f99-cce4-4ecb-9b92-80825a36780c
# ╟─a4b8fc31-c021-4acd-8857-8e30095f359b
# ╟─4ab8b6d7-7cef-4342-a277-1589e48b8271
