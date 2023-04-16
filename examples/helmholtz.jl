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

	Pkg.activate(".")
end

# ╔═╡ d5e4c4f6-7b9f-483b-b517-45ecfa59930c
using Revise, Unitful, Coils, Plots, PlutoUI

# ╔═╡ 0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
md"""
# Helmholtz

The present notebook visualizes the magnetic flux density created by a Helmholtz coil.
"""

# ╔═╡ 0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
md"Current: $(@bind current_A NumberField(1:300, default=100)) A"

# ╔═╡ ea2b5c38-6557-4d98-ad4f-6f2b295ace00
current = current_A * 1u"A"

# ╔═╡ a5780f99-cce4-4ecb-9b92-80825a36780c
md"Inner radius $(@bind inner_radius_mm NumberField(1:100, default=30)) mm"

# ╔═╡ 3b664bb8-0443-492a-bd26-575a0952a759
inner_radius = inner_radius_mm * 1u"mm"

# ╔═╡ a5556fc2-9f5e-41c8-81b5-01678d78e9a3
md"Outer radius $(@bind outer_radius_mm NumberField(1:100, default=40)) mm"

# ╔═╡ 76932e3f-1174-4a1f-ae77-c5c7b1f55662
outer_radius = outer_radius_mm * 1u"mm"

# ╔═╡ ffe05385-89ee-4f4c-b3a4-8e9ce180316c
md"Length $(@bind length_mm NumberField(1:100, default=10)) mm"

# ╔═╡ 13794b21-ad40-42f6-95e6-3b522a9253c9
length = length_mm * 1u"mm"

# ╔═╡ b2544144-04ad-4c2e-a292-e0657122545e
md"Number of axial turns $(@bind axial_turns_int NumberField(2:2:10, default=4))"

# ╔═╡ 67194ace-46e1-4dff-8bec-4984c2bcd66c
axial_turns = UInt8(axial_turns_int)

# ╔═╡ a4b8fc31-c021-4acd-8857-8e30095f359b
md"Number of radial turns: $(@bind radial_turns_int NumberField(1:12, default=6))"

# ╔═╡ 7bd3792a-ac85-4eb4-bb10-f439e7b3eceb
radial_turns = UInt8(radial_turns_int)

# ╔═╡ 42e2bc75-4aa5-4a70-b792-133c673cbe2a
md"Separation: $(@bind separation_mm NumberField(1:40, default=20)) mm"

# ╔═╡ 0b4c5b72-8172-44c7-bd62-9c8dab2e31b1
separation = separation_mm * 1u"mm"

# ╔═╡ e1f37829-63b1-4e92-a1fd-8adf57dbc787
effective_radius = (outer_radius + inner_radius) / 2

# ╔═╡ 7f94dd7b-6eb9-4abf-88c9-1e7b8dcea8a3
total_turns = axial_turns * radial_turns

# ╔═╡ f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
coil = Helical(
	current=current,
	inner_radius=inner_radius,
	outer_radius=outer_radius,
	length=length,
	axial_turns=axial_turns,
	radial_turns=radial_turns,
)

# ╔═╡ ff1eace0-8a39-43a0-b9d6-b401752de505
helmholtz = Helmholtz(coil=coil, separation=separation)

# ╔═╡ debd08c3-e572-4722-8af9-49a2d6da161d
helmholtz_loops = CurrentLoops(helmholtz)

# ╔═╡ 7f6accc1-fdf3-4c13-a233-63a72fab8758
let
	ρ = LinRange(0u"mm", 1.2outer_radius, 100)
	z = 0.0u"m"
	
	plot(ρ, hcat(mfd.(Ref(helmholtz_loops), ρ, z)...)',
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Radial z=0",
    	xlabel="Radial coordinate ρ",
    	ylabel="Magnetic flux density B",
  	)

	vline!(map(x -> x[1], conductor_coordinates(helmholtz_loops)), label="")
end

# ╔═╡ 6e9fa275-ecd3-4724-8647-a55e0671dd4b
let
	ρ = 0.0u"m"
	z = LinRange(-1.2separation, 1.2separation, 100)
	
	plot(z, hcat(mfd.(Ref(helmholtz_loops), ρ, z)...)',
		seriestype=:scatter,
		markers=[:circle :hex],
		labels=["Bρ" "Bz"],
		title="Axial ρ=0",
		xlabel="Axial coordinate z",
		ylabel="Magnetic flux density B",
  	)

	hline!([mfdz(helmholtz)[2]],
		label="",
		color="black",
		linewidth=2,
	)

	vline!(map(x -> x[2], conductor_coordinates(helmholtz_loops)), label="")
end

# ╔═╡ e46d04f9-aa32-40fd-88d4-55d1fcf3c8d2
md"""
where the black line denotes the approximation

$$B^z(0,0)=
\frac{8\mu_0}{\sqrt{125}}\frac{NI}{R_\text{eff}}
\tag{1}
,$$

wherein $N$ is the number of total turns and $R_\text{eff}$ is the effective radius.
"""

# ╔═╡ 4addeaee-d686-4dfb-85d5-e473ae826fb1
md"""
# Anti-Helmholtz
"""

# ╔═╡ f719c7bc-52f8-4bd0-95f7-73311ad2e78d
md"Separation: $(@bind anti_separation_mm NumberField(1:40, default=20)) mm"

# ╔═╡ 185657cf-bf8f-4eb9-a5fd-7f2300af5b68
begin
	anti_separation = anti_separation_mm * 1u"mm"
end;

# ╔═╡ 34683b0d-3816-4876-82c5-9296f64c36dc
anti_helmholtz = AntiHelmholtz(coil=coil, separation=anti_separation)

# ╔═╡ 3890b579-a42e-492b-9fbc-a731498ba97f
anti_helmholtz_loops = CurrentLoops(anti_helmholtz)

# ╔═╡ 0cb240cc-0d01-4d9c-bb6c-229f0ebbd28e
let
	ρ = LinRange(0u"mm", 1.2outer_radius, 100)
	z = 0.0u"m"
	
	plot(ρ, hcat(mfd.(Ref(anti_helmholtz_loops), ρ, z)...)',
    	seriestype=:scatter,
    	markers=[:circle :hex],
    	labels=["Bρ" "Bz"],
    	title="Radial z=0",
    	xlabel="Radial coordinate ρ",
    	ylabel="Magnetic flux density B",
  	)

	vline!(map(x -> x[1], conductor_coordinates(anti_helmholtz_loops)), label="")
end

# ╔═╡ 4aa0d5ae-97fd-4179-9836-9b11ce516927
let
	ρ = 0.0u"m"
	z = LinRange(-1.2separation, 1.2separation, 100)
	
	plot(z, hcat(mfd.(Ref(anti_helmholtz_loops), ρ, z)...)',
		seriestype=:scatter,
		markers=[:circle :hex],
		labels=["Bρ" "Bz"],
		title="Axial ρ=0",
		xlabel="Axial coordinate z",
		ylabel="Magnetic flux density B",
  	)

	hline!([mfdz(anti_helmholtz)[2]],
		label="",
		color="black",
		linewidth=2,
	)

	vline!(map(x -> x[2], conductor_coordinates(anti_helmholtz_loops)), label="")
end

# ╔═╡ Cell order:
# ╠═ae9a85d0-b0f2-11ed-161e-f355a5ee436b
# ╠═d5e4c4f6-7b9f-483b-b517-45ecfa59930c
# ╟─0131c72f-2d93-4d2a-b7a5-e77ce9f2e427
# ╟─0c0e7372-ec1e-4252-9e67-2a3d0aefd7de
# ╟─ea2b5c38-6557-4d98-ad4f-6f2b295ace00
# ╟─a5780f99-cce4-4ecb-9b92-80825a36780c
# ╟─3b664bb8-0443-492a-bd26-575a0952a759
# ╟─a5556fc2-9f5e-41c8-81b5-01678d78e9a3
# ╟─76932e3f-1174-4a1f-ae77-c5c7b1f55662
# ╟─ffe05385-89ee-4f4c-b3a4-8e9ce180316c
# ╟─13794b21-ad40-42f6-95e6-3b522a9253c9
# ╟─b2544144-04ad-4c2e-a292-e0657122545e
# ╟─67194ace-46e1-4dff-8bec-4984c2bcd66c
# ╟─a4b8fc31-c021-4acd-8857-8e30095f359b
# ╟─7bd3792a-ac85-4eb4-bb10-f439e7b3eceb
# ╟─42e2bc75-4aa5-4a70-b792-133c673cbe2a
# ╟─0b4c5b72-8172-44c7-bd62-9c8dab2e31b1
# ╟─e1f37829-63b1-4e92-a1fd-8adf57dbc787
# ╟─7f94dd7b-6eb9-4abf-88c9-1e7b8dcea8a3
# ╟─f2d60367-d4f9-480c-ac5c-75c3ff0eb74a
# ╟─ff1eace0-8a39-43a0-b9d6-b401752de505
# ╟─debd08c3-e572-4722-8af9-49a2d6da161d
# ╟─7f6accc1-fdf3-4c13-a233-63a72fab8758
# ╟─6e9fa275-ecd3-4724-8647-a55e0671dd4b
# ╟─e46d04f9-aa32-40fd-88d4-55d1fcf3c8d2
# ╟─4addeaee-d686-4dfb-85d5-e473ae826fb1
# ╟─f719c7bc-52f8-4bd0-95f7-73311ad2e78d
# ╟─185657cf-bf8f-4eb9-a5fd-7f2300af5b68
# ╠═34683b0d-3816-4876-82c5-9296f64c36dc
# ╠═3890b579-a42e-492b-9fbc-a731498ba97f
# ╟─0cb240cc-0d01-4d9c-bb6c-229f0ebbd28e
# ╟─4aa0d5ae-97fd-4179-9836-9b11ce516927
