### A Pluto.jl notebook ###
# v0.20.0

using Markdown
using InteractiveUtils

# ╔═╡ 62527ae8-4a61-470c-8ad4-422f6b6850c9
begin

using Pkg

Pkg.activate(".")

end

# ╔═╡ b99dc34a-c110-468c-8c8a-a8ce811158ad
begin

using LinearAlgebra
using DynamicQuantities
using HeatTransferFluids
using Coils
using ElectricWires
using Plots

end

# ╔═╡ 7687ff40-8096-11ef-1ab1-9151f7c8588d
md"""
# Primary magnetic coils
"""

# ╔═╡ 0f6de003-dbd1-4116-a5f5-259e599119a8
fov = 260u"um"

# ╔═╡ a2808d52-a50c-4d6d-abbd-4c8d695881b9
water = Water(
	velocity = 2u"m/s",
	temperature = 293.15u"K",
)

# ╔═╡ 79033882-61a0-47be-b03d-c340e55ff9e8
mfdmax(coil) = norm(magnetic_flux_density(coil, 0u"m", 0u"m", 0u"m"))

# ╔═╡ 95f3a695-9bda-42ef-b1d9-d1098c8eedf1
mfdinhomo(coil) = norm(magnetic_flux_density(coil, 1u"mm"+fov/2, 1u"mm"+fov/2, 0u"m") .- magnetic_flux_density(coil, 1u"mm", 1u"mm", 0u"m"))

# ╔═╡ b6633e09-0c8e-40a0-ab80-6820a2d4e334
mfdgrad(coil) = (magnetic_flux_density(coil, 0u"m", 0u"m", 10u"um")[3]-magnetic_flux_density(coil, 0u"m", 0u"m", -10u"um")[3])/20u"um"

# ╔═╡ 15f467b0-9f72-4132-b8e9-d5d21a39fb40
function wheeler_inductance(inner_diameter, outer_diameter, thickness, turns)
	w_axial = ustrip(thickness |> us"inch")
	w_radial = ustrip(((outer_diameter - inner_diameter) / 2) |> us"inch")
	R = w_radial / 2 + ustrip(inner_diameter |> us"inch")
	N = turns

	return 1e-6us"H" * (.8 * R^2 * N^2)/(6*R + 9*w_axial + 10*w_radial)
end

# ╔═╡ a5fd87f4-f7ee-4517-9cc5-9f244a7c5b6c
md"""
## Objective coils
"""

# ╔═╡ 2e81c727-d8b4-4e15-996c-eb7cc5490b14
objcoil_current = 400u"A"

# ╔═╡ 89f3fb1e-c5c1-4fdc-9b49-69740705e42e
objcoil_radial_turns = 14

# ╔═╡ b49eae6e-ba88-42f6-a79a-aa6162ef4fb6
objcoil_axial_turns = 2

# ╔═╡ 5c9939a1-c76b-4567-b812-b5b62738d195
objcoil_inner_diameter = 94.1u"mm"

# ╔═╡ 2ba54cc1-60bd-4d5a-a499-8b84b0047603
objcoil_glue_thickness = 0u"mm"

# ╔═╡ 7ddeb4e2-5264-452b-9014-2589d520905a
objcoil_wire_radial_length = 5.0u"mm"

# ╔═╡ 1a65560b-5e71-4321-943f-ef39fc4c8da0
objcoil_wire_axial_length = 5.0u"mm"

# ╔═╡ 73083757-7f01-4822-b8c6-cf1aa7c269b5
objcoil_wire_hole_diameter = 3.0u"mm"

# ╔═╡ bceb2a11-be3c-48d6-8837-26fbd3bc77ea
objcoil_wire_radial_spacing = 0.2u"mm"

# ╔═╡ e0f52e82-25f6-48df-9768-297c5ba93270
objcoil_wire_axial_spacing = 0.2u"mm"

# ╔═╡ f66a434b-a69f-4a08-a709-de71c1b8a47e
objcoil_outer_diameter = objcoil_inner_diameter + 2*(0*objcoil_glue_thickness + objcoil_radial_turns*objcoil_wire_radial_length+(objcoil_radial_turns-1)*objcoil_wire_radial_spacing)

# ╔═╡ b11af2cb-9908-4513-9e3c-d23839cb0dd4
objcoil_thickness = 0*objcoil_glue_thickness + objcoil_axial_turns*objcoil_wire_axial_length+(objcoil_axial_turns-1)*objcoil_wire_axial_spacing

# ╔═╡ 93916065-2494-4852-a039-8d28b7dd8084
objcoil_spacing = 126u"mm"

# ╔═╡ c161b3c3-55e9-4c0a-9fbf-c8e7fee076ac
objcoil_loops = CircularCoil(
    current=objcoil_current,
    radial_turns=objcoil_radial_turns,
    axial_turns=objcoil_axial_turns,
    inner_diameter=objcoil_inner_diameter,
    outer_diameter=objcoil_outer_diameter,
    thickness=objcoil_thickness,
)

# ╔═╡ a923b951-a150-45a5-8a1b-5d4d6eb1466a
objcoil_wire = Wire(
	profile=RectangularHollowProfile(
		width = objcoil_wire_radial_length,
		height = objcoil_wire_axial_length,
		hole_diameter = objcoil_wire_hole_diameter,
	),
	material=Cu,
	length=conductor_length(objcoil_loops),
)

# ╔═╡ 1f181ebf-74a4-40aa-98c9-efe61422d825
objcoil_tube = Tube(
	diameter = objcoil_wire_hole_diameter,
	length = objcoil_wire.length,
)

# ╔═╡ 9e17da37-b8d9-4330-b4b9-dde01105e7ab
objcoil_homo = Helmholtz(objcoil_loops, distance=objcoil_spacing)

# ╔═╡ 4fd9c0f2-0315-4ff8-80af-2c7b5913dba8
objcoil_grad = AntiHelmholtz(objcoil_loops, distance=objcoil_spacing)

# ╔═╡ aced6467-82cd-44d3-a1fc-ee3195b32fe5
round(mfdmax(objcoil_homo) |> us"Gauss")

# ╔═╡ 807e74dc-c4be-44fa-8ae8-deef2d657608
mfdinhomo(objcoil_homo) |> us"Gauss"

# ╔═╡ efd570d4-d7b4-4f97-bf48-1af06d398cbb
mfdinhomo(objcoil_homo) / mfdmax(objcoil_homo)

# ╔═╡ 29d32e07-d324-4e8e-866e-84b719be3b75
round(mfdgrad(objcoil_grad) |> us"Gauss/cm")

# ╔═╡ 4cf0d6da-37ae-453e-aacd-987e9b59830c
weight(objcoil_wire) |> us"kg"

# ╔═╡ 0e777c99-e672-403d-acad-14b7e160f4de
resistance(objcoil_wire)

# ╔═╡ d9989bbd-72bc-44fa-a407-cd791ad160b2
pressure_drop(water, objcoil_tube)

# ╔═╡ e1b3ba15-a5a7-45d9-88f8-e3f98b01c7d1
pressure_drop(water, Helix(
	objcoil_tube,
	diameter = objcoil_outer_diameter,
	pitch = objcoil_wire_hole_diameter,
))

# ╔═╡ 54fb7b0e-5458-41c1-aa16-b6ea47033788
resistance(objcoil_wire) * objcoil_current^2 |> us"kW"

# ╔═╡ e52cf867-1264-42c4-b8d4-029ba1e7be67
wheeler_inductance(objcoil_inner_diameter, objcoil_outer_diameter, objcoil_thickness, objcoil_axial_turns * objcoil_radial_turns) |> us"H" 

# ╔═╡ f5d2be87-428e-4e98-aafb-5e37915dad50
let

	ρ = range(-fov, fov, 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(objcoil_homo, ρ, 0u"m", z)) for ρ in ρ]

	plot(
		ustrip.(ρ) / 1e-6,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm)")
	xlabel!("Radial coordinate ρ (um)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 44d4ed9b-9327-433c-8056-226afc440136
let
	ρ = range(-1u"mm", 1u"mm", 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(objcoil_homo, ρ, 0u"m", z)) for ρ in ρ]

	plot(
		ustrip.(ρ) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm)")
	xlabel!("Radial coordinate ρ (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 8e9d745f-09c0-426e-803f-d9bb8ca1ea2b
let
	ρ = range(-1u"mm", 1u"mm", 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(objcoil_grad, ρ, 0u"m", z)) for ρ in ρ]

	plot(
		ustrip.(ρ) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (z = 0 mm)")
	xlabel!("Radial coordinate ρ (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ bc48fb0e-f8ff-49f3-9a83-9e5c60874352
let
	ρ = 0u"mm"
	z = range(-objcoil_spacing/2, objcoil_spacing/2, 100)

	B = [norm(magnetic_flux_density(objcoil_homo, ρ, 0u"m", z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (ρ = 0 mm)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ de4b9a1d-d50b-4464-a12f-25f30bc15754
let
	ρ = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(objcoil_homo, ρ, 0u"m", z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (ρ = 0 mm)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 7935ee56-38e6-48d4-ae9b-400c6acab27a
let
	ρ = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(objcoil_grad, ρ, 0u"m", z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (ρ = 0 mm)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ dc97da7a-d3c7-484e-9c98-68b567a6a9e2
let
	ρ = 0u"mm"
	z = range(-objcoil_spacing/2, objcoil_spacing/2, 100)

	B = [norm(magnetic_flux_density(objcoil_grad, ρ, 0u"m", z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (ρ = 0 mm)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 77b3e8d5-3dcc-445d-b120-ec9f88d1ee93
md"""
## Sagital coils
"""

# ╔═╡ 33219d81-8f7f-4b04-ab26-89d74b9324e6
sagcoil_current = 100u"A"

# ╔═╡ 9c4bf868-1259-40a7-9506-be3295970e9c
sagcoil_radial_turns = 4

# ╔═╡ c46e9d35-86c9-4e8c-9979-b0fdd2356802
sagcoil_axial_turns = 4

# ╔═╡ b2f1d5fa-70ab-4922-bb61-d303c7cf616e
sagcoil_inner_width = 230u"mm"

# ╔═╡ 3b9f7b15-7ce9-4d54-8649-4430e0ad3fd9
sagcoil_inner_height = 60u"mm"

# ╔═╡ 47f4caab-fa4f-410a-833f-79367388b5a6
sagcoil_glue_thickness = 0u"mm"

# ╔═╡ 80493ac0-ebe2-4cc7-988b-1cc85af602d9
sagcoil_wire_axial_length = 5u"mm"

# ╔═╡ f489b38c-82a4-4b78-b128-b5cc1512bff8
sagcoil_wire_radial_length = 5u"mm"

# ╔═╡ 819cc8e0-36b1-4442-aabc-7d8b230d9fd9
sagcoil_wire_hole_diameter = 3u"mm"

# ╔═╡ 0cbfc5eb-58a0-4814-893e-2d7d4837d8b6
sagcoil_outer_width = sagcoil_inner_width + 2*(2*sagcoil_glue_thickness + sagcoil_radial_turns * sagcoil_wire_radial_length)

# ╔═╡ d917888f-893a-42ac-8217-cc2d501307b6
sagcoil_outer_height = sagcoil_inner_height + 2*(2*sagcoil_glue_thickness + sagcoil_radial_turns * sagcoil_wire_radial_length)

# ╔═╡ 739810fa-61d8-4258-9fa2-a54f3d463c3a
sagcoil_thickness = 2 * sagcoil_glue_thickness + sagcoil_axial_turns * sagcoil_wire_axial_length

# ╔═╡ cdac8d4c-e4ac-4880-85ba-913ff89400ad
sagcoil_loops = RectangularCoil(
	current=sagcoil_current,
	radial_turns=sagcoil_radial_turns,
	axial_turns=sagcoil_axial_turns,
	inner_width=sagcoil_inner_width,
	outer_width=sagcoil_outer_width,
	inner_height=sagcoil_inner_height,
	outer_height=sagcoil_outer_height,
	thickness=sagcoil_thickness,
)

# ╔═╡ 9f93a288-2761-40d3-b045-c0fabb06d8fa
sagcoil_wire = Wire(
	profile=RectangularHollowProfile(
		width = sagcoil_wire_radial_length,
		height = sagcoil_wire_axial_length,
		hole_diameter = sagcoil_wire_hole_diameter,
	),
	material=Cu,
	length=conductor_length(sagcoil_loops),
)

# ╔═╡ ac251c58-4dab-4ef8-8ac5-7b1d3d36bb4d
sagcoil_tube = Tube(
	diameter = sagcoil_wire_hole_diameter,
	length = sagcoil_wire.length,
)

# ╔═╡ d4857ff6-42ad-4c2f-bc6b-b0590a0e83f6
sagcoil_bend_radius = 30u"mm"

# ╔═╡ 911257b1-a25e-448e-b785-682359513b27
sagcoil_spacing = 90u"mm"

# ╔═╡ c6bb642b-43df-40f6-b3f9-dc3bf0d3fb79
sagcoil_homo = Helmholtz(sagcoil_loops, distance=sagcoil_spacing)

# ╔═╡ c770d6b9-74b1-49f7-81af-dd9456d27d1f
sagcoil_grad = AntiHelmholtz(sagcoil_loops, distance=sagcoil_spacing)

# ╔═╡ 843721c4-d5d0-42dd-91cb-212703b492fd
round(mfdmax(sagcoil_homo) |> us"Gauss")

# ╔═╡ 2f4163b0-32d7-46f9-aa23-bd5d36026cd8
mfdinhomo(sagcoil_homo) |> us"Gauss"

# ╔═╡ 550ac45b-d0a7-4fcc-b395-dccf4f289319
mfdinhomo(sagcoil_homo) / mfdmax(sagcoil_homo)

# ╔═╡ 1a682c5c-137a-48c0-b1bf-a9b0b8c113c2
round(mfdgrad(sagcoil_grad) |> us"Gauss/cm")

# ╔═╡ d07af222-5968-44c4-8de0-c21ec8ce417f
weight(sagcoil_wire) |> us"kg"

# ╔═╡ 66236dc8-f4f0-4427-92a0-70afb9f4fc29
resistance(sagcoil_wire)

# ╔═╡ 3b1ef34d-7f84-4c3e-a519-d5a4b36bb499
pressure_drop(water, sagcoil_tube)

# ╔═╡ feb966ce-8fb7-41c7-9f95-6449ae0ffb74
pressure_drop(water, Helix(
	sagcoil_tube,
	diameter = (sagcoil_inner_height + sagcoil_outer_height + sagcoil_inner_width + sagcoil_outer_width) / 4,
	pitch = sagcoil_wire_axial_length + sagcoil_wire_radial_length,
))

# ╔═╡ 12f69d23-bff9-4297-adc2-839150a09375
pressure_drop(water, Elbow(sagcoil_tube, radius = sagcoil_bend_radius))

# ╔═╡ de20d83d-2276-455c-b472-ed8e49030160
resistance(sagcoil_wire) * sagcoil_current^2 |> us"kW"

# ╔═╡ e0a8cc52-ff50-4ad0-901f-88c634a6b66b
wheeler_inductance(sagcoil_inner_height, sagcoil_outer_height, sagcoil_thickness, sagcoil_axial_turns * sagcoil_radial_turns) |> us"H"

# ╔═╡ 63228e37-c463-41c8-9e98-9e93da95ad63
wheeler_inductance(sagcoil_inner_width, sagcoil_outer_width, sagcoil_thickness, sagcoil_axial_turns * sagcoil_radial_turns) |> us"H"

# ╔═╡ 2ccae8a3-1da0-4329-8f5c-ba9662f64ef3
let

	x = range(-fov, fov, 100)
	y = 0u"mm"
	z = 0u"mm"

	B = [norm(magnetic_flux_density(sagcoil_homo, x, y, z)) for x in x]

	plot(
		ustrip.(x) / 1e-6,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = y)")
	xlabel!("Transverse coordinate x (um)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ a9ed0b70-1fb3-4bfb-8d5c-cd55d14ddc27
let
	x = 0u"mm"
	y = range(-fov, fov, 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(sagcoil_homo, x, y, z)) for y in y]

	plot(
		ustrip.(y) / 1e-6,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = x)")
	xlabel!("Transverse coordinate y (um)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ dbe3e527-0b59-45eb-842c-bff079e327d2
let
	x = range(-1u"mm", 1u"mm", 100)
	y = 0u"mm"
	z = 0u"mm"

	B = [norm(magnetic_flux_density(sagcoil_homo, x, y, z)) for x in x]

	plot(
		ustrip.(x) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = y)")
	xlabel!("Transverse coordinate x (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 4fad0eb0-6e82-46b4-9f72-7829efaf751f
let
	x = 0u"mm"
	y = range(-1u"mm", 1u"mm", 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(sagcoil_homo, x, y, z)) for y in y]

	plot(
		ustrip.(y) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = x)")
	xlabel!("Transverse coordinate y (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ c37a8a6e-f9bd-47d5-aaaf-0939d15a51c6
let
	x = range(-1u"mm", 1u"mm", 100)
	y = 0u"mm"
	z = 0u"mm"

	B = [norm(magnetic_flux_density(sagcoil_grad, x, y, z)) for x in x]

	plot(
		ustrip.(x) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (z = 0 mm = y)")
	xlabel!("Transverse coordinate x (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ c9a6a696-6818-4ed5-ac87-028f764ad0f6
let
	x = 0u"mm"
	y = range(-1u"mm", 1u"mm", 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(sagcoil_grad, x, y, z)) for y in y]

	plot(
		ustrip.(y) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (z = 0 mm = x)")
	xlabel!("Transverse coordinate y (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ d3894890-4b97-498d-9d9e-db29577caae9
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-sagcoil_spacing/2, sagcoil_spacing/2, 100)

	B = [norm(magnetic_flux_density(objcoil_homo, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ c56ce2b2-8fd2-427b-9d6e-26dbe0ce8799
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(sagcoil_homo, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 5a99e920-a278-4d20-8eed-ef3bb86ef7dd
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(sagcoil_grad, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ c50a7899-e586-4676-98b4-5910120a8177
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-objcoil_spacing/2, objcoil_spacing/2, 100)

	B = [norm(magnetic_flux_density(objcoil_grad, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ fa1683c2-cfab-426f-976f-6be38033d42f
md"""
## Frontal coils
"""

# ╔═╡ 9f079605-3957-40ff-87cb-c616709431b2
frontcoil_current = 400u"A"

# ╔═╡ e471acb5-dea8-4326-9233-b73f2ee1fd3b
frontcoil_radial_turns = 2

# ╔═╡ f4a035d9-d598-4c08-bd83-f30d665b1581
frontcoil_axial_turns = 4

# ╔═╡ b069792c-d0da-49e3-83a7-9e79e771ae82
frontcoil_inner_width = 42.1u"mm"

# ╔═╡ 9f2651e9-f5b9-4a40-9551-43942cd579ce
frontcoil_inner_height = 86.1u"mm"

# ╔═╡ dab79091-942c-4444-ae56-5a02f525b169
frontcoil_glue_thickness = 1u"mm"

# ╔═╡ bd4c3584-31a0-49d2-b32f-8153c8175b2e
frontcoil_wire_radial_length = 3.0u"mm"

# ╔═╡ 6bd61132-3a4b-4d6b-aa18-aded7dab3f7b
frontcoil_wire_axial_length = 3.0u"mm"

# ╔═╡ e0db485e-9b23-4ac3-9d0a-0e7ee39f191c
frontcoil_wire_hole_diameter = 1.5u"mm"

# ╔═╡ 71546c45-d533-41a7-ab3d-5d4891e04400
frontcoil_spacing = 130u"mm"

# ╔═╡ 77ccf7b0-6743-4a9d-8a82-787dce694072
frontcoil_outer_width = frontcoil_inner_width + 2*(2*frontcoil_glue_thickness + frontcoil_radial_turns * frontcoil_wire_radial_length)

# ╔═╡ 86180b76-68c6-4916-9707-09fa0d34fc04
frontcoil_outer_height = frontcoil_inner_height + 2*(2*frontcoil_glue_thickness + frontcoil_radial_turns * frontcoil_wire_radial_length)

# ╔═╡ 01c9269b-3d64-4f3e-8746-29a5ac82f6c1
frontcoil_thickness = 2*(2*frontcoil_glue_thickness + frontcoil_axial_turns * frontcoil_wire_axial_length)

# ╔═╡ f7b60c19-1080-45a3-ba37-356c25dd4756
frontcoil_loops = RectangularCoil(
    current=frontcoil_current,
    radial_turns=frontcoil_radial_turns,
    axial_turns=frontcoil_axial_turns,
    inner_width=frontcoil_inner_width,
    outer_width=frontcoil_outer_width,
	inner_height=frontcoil_inner_height,
	outer_height=frontcoil_outer_height,
    thickness=frontcoil_thickness,
)

# ╔═╡ 5ea85756-468b-403a-af48-1eb79bf9a45e
frontcoil_wire = Wire(
	profile=RectangularHollowProfile(
		width=frontcoil_wire_axial_length,
		height=frontcoil_wire_radial_length,
		hole_diameter=frontcoil_wire_hole_diameter,
	),
	material=Cu,
	length=conductor_length(frontcoil_loops),
)

# ╔═╡ dfe691aa-63b4-4718-9657-47a707ab7979
frontcoil_tube = Tube(
	diameter = frontcoil_wire_hole_diameter,
	length = frontcoil_wire.length,
)

# ╔═╡ a1587732-25ff-414c-a198-9a6552ca1e88
frontcoil_homo = Helmholtz(frontcoil_loops, distance=frontcoil_spacing)

# ╔═╡ 5f27d9bf-4c05-41c1-8385-c0f739eb6abb
frontcoil_grad = AntiHelmholtz(frontcoil_loops, distance=frontcoil_spacing)

# ╔═╡ 9b936cbc-1a8f-466b-8b4a-1b9d9889d445
round(mfdmax(frontcoil_homo) |> us"Gauss")

# ╔═╡ 1cebf21d-e330-4779-8659-21d637b10e92
mfdinhomo(frontcoil_homo) |> us"Gauss"

# ╔═╡ 3815acad-7614-4a78-a8ff-b9a0580adb4d
round(mfdgrad(frontcoil_grad) |> us"Gauss/cm")

# ╔═╡ 274b9059-cc44-4226-a4fd-a35e88dec084
resistance(frontcoil_wire)

# ╔═╡ 1c75d8be-7521-4cac-9ece-d03e2019e104
resistance(frontcoil_wire) * frontcoil_current^2 |> us"kW"

# ╔═╡ 03cfaa0b-8442-4969-9e98-660e71a468e9
weight(frontcoil_wire) |> us"kg"

# ╔═╡ 785601e7-0456-4b74-9730-325605ec923d
pressure_drop(water, frontcoil_tube)

# ╔═╡ 2d2ba987-5a03-4530-9abe-cc5726eab943
pressure_drop(water, Helix(
	frontcoil_tube,
	diameter = (frontcoil_inner_height + frontcoil_outer_height + frontcoil_inner_width + frontcoil_outer_width) / 4,
	pitch = frontcoil_wire_hole_diameter,
))

# ╔═╡ 42d10eba-1284-497b-a720-b84389c6e37c
wheeler_inductance(frontcoil_inner_height, frontcoil_outer_height, frontcoil_thickness, frontcoil_axial_turns * frontcoil_radial_turns) |> us"H"

# ╔═╡ 34b21dd7-82b5-426e-a45c-ab4a50670ebc
wheeler_inductance(frontcoil_inner_width, frontcoil_outer_width, frontcoil_thickness, frontcoil_axial_turns * frontcoil_radial_turns) |> us"H"

# ╔═╡ 4f86c676-8819-418d-b467-bb65339e1b48
let

	x = range(-fov, fov, 100)
	y = 0u"mm"
	z = 0u"mm"

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for x in x]

	plot(
		ustrip.(x) / 1e-6,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = y)")
	xlabel!("Transverse coordinate x (um)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 5e50a684-d480-4a2e-83fb-4635f6c8bf12
let
	x = 0u"mm"
	y = range(-fov, fov, 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for y in y]

	plot(
		ustrip.(y) / 1e-6,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = x)")
	xlabel!("Transverse coordinate y (um)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 522a7064-995f-47d9-aba7-d8bc4c8ec26b
let
	x = range(-1u"mm", 1u"mm", 100)
	y = 0u"mm"
	z = 0u"mm"

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for x in x]

	plot(
		ustrip.(x) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = y)")
	xlabel!("Transverse coordinate x (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 8eed558f-942a-4613-9177-80a9b21628ec
let
	x = 0u"mm"
	y = range(-1u"mm", 1u"mm", 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for y in y]

	plot(
		ustrip.(y) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (z = 0 mm = x)")
	xlabel!("Transverse coordinate y (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 51f51bce-1352-4d60-8a3a-6ff0300172df
let
	x = range(-1u"mm", 1u"mm", 100)
	y = 0u"mm"
	z = 0u"mm"

	B = [norm(magnetic_flux_density(frontcoil_grad, x, y, z)) for x in x]

	plot(
		ustrip.(x) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (z = 0 mm = y)")
	xlabel!("Transverse coordinate x (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ acf02cec-247c-466f-b808-ca5956a84c37
let
	x = 0u"mm"
	y = range(-1u"mm", 1u"mm", 100)
	z = 0u"mm"

	B = [norm(magnetic_flux_density(frontcoil_grad, x, y, z)) for y in y]

	plot(
		ustrip.(y) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (z = 0 mm = x)")
	xlabel!("Transverse coordinate y (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 4a29319e-970f-4483-ac95-b7dbcf60d392
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-frontcoil_spacing/2, frontcoil_spacing/2, 100)

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 03a0dad0-4eae-42a1-b48d-0c7653742109
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ fde253e8-74d9-4439-a61d-97c450a0e6dd
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(frontcoil_homo, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Homogeneous (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ ac599ebb-b490-4fd8-b456-de6ccc715d73
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-1u"mm", 1u"mm", 100)

	B = [norm(magnetic_flux_density(frontcoil_grad, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ a2195ced-eab0-45bf-b0c9-0a4407af8f60
let
	x = 0u"mm"
	y = 0u"mm"
	z = range(-objcoil_spacing/2, objcoil_spacing/2, 100)

	B = [norm(magnetic_flux_density(frontcoil_grad, x, y, z)) for z in z]

	plot(
		ustrip.(z) / 1e-3,
		ustrip.(B) / 1e-4,
		marker=:cross,
		legend=:false,
	)
	title!("Gradient (x = 0 mm = y)")
	xlabel!("Axial coordinate z (mm)")
	ylabel!("Magnetic flux density (Gauss)")
end

# ╔═╡ 4a1dbb5c-6f8d-449e-8b33-219d4407daf5
shimcoil_current = 20u"A"

# ╔═╡ ea1788c0-ff74-4a43-b0e2-c4f6b01bfe21
shimcoil_radial_turns = 10

# ╔═╡ 594e0227-0c11-422a-9ee9-d44e3907a729
shimcoil_axial_turns = 2

# ╔═╡ d815bc19-ab79-4c3b-b33e-134373454244
shimcoil_inner_diameter = 100u"mm"

# ╔═╡ e17c7dd0-25b1-4fcf-a684-9982e33bc729
shimcoil_wire_radial_length = 3.0u"mm"

# ╔═╡ 1186a037-518e-4d0b-95f2-502dd55feddd
shimcoil_wire_axial_length = 3.0u"mm"

# ╔═╡ 9a7fc6f8-63f9-4133-9543-c81288f91bbd
shimcoil_wire_radial_spacing = 0.02u"mm"

# ╔═╡ 0cde4a0d-4f28-4201-ad91-274eed2abff2
shimcoil_wire_axial_spacing = 0.02u"mm"

# ╔═╡ d34f0813-a5cc-4551-a4c7-e9b309fac679
shimcoil_outer_diameter = shimcoil_inner_diameter + 2*(shimcoil_radial_turns*shimcoil_wire_radial_length+(shimcoil_radial_turns-1)*shimcoil_wire_radial_spacing)

# ╔═╡ 4376a1ce-8e9b-41fe-963c-27df205925f1
shimcoil_thickness = shimcoil_axial_turns*shimcoil_wire_axial_length+(shimcoil_axial_turns-1)*shimcoil_wire_axial_spacing

# ╔═╡ ce58ea06-cc92-499c-a221-44267f1a63c9
shimcoil_spacing = 145u"mm"

# ╔═╡ 7963a153-e898-4c81-af8e-c7b18475f03f
shimcoil_loops = CircularCoil(
    current=shimcoil_current,
    radial_turns=shimcoil_radial_turns,
    axial_turns=shimcoil_axial_turns,
    inner_diameter=shimcoil_inner_diameter,
    outer_diameter=shimcoil_outer_diameter,
    thickness=shimcoil_thickness,
)

# ╔═╡ cb337784-7e49-4ebb-8014-674c9284a50a
shimcoil_homo = Helmholtz(shimcoil_loops, distance=shimcoil_spacing)

# ╔═╡ 53e44268-c0c7-420c-8aec-8548289fb96c
shimcoil_wire = Wire(
	profile=RectangularProfile(
		width = shimcoil_wire_radial_length,
		height = shimcoil_wire_axial_length,
	),
	material=Cu,
	length=conductor_length(shimcoil_loops),
)

# ╔═╡ 25dd78fc-9617-49c7-adff-83d1d1e8b618
round(mfdmax(shimcoil_homo) |> us"Gauss")

# ╔═╡ d1c8e68f-4ffc-4a9a-b200-7b84beb7c4da
resistance(shimcoil_wire) * shimcoil_current^2 |> us"W"

# ╔═╡ Cell order:
# ╟─7687ff40-8096-11ef-1ab1-9151f7c8588d
# ╟─62527ae8-4a61-470c-8ad4-422f6b6850c9
# ╟─b99dc34a-c110-468c-8c8a-a8ce811158ad
# ╟─0f6de003-dbd1-4116-a5f5-259e599119a8
# ╠═a2808d52-a50c-4d6d-abbd-4c8d695881b9
# ╠═79033882-61a0-47be-b03d-c340e55ff9e8
# ╠═95f3a695-9bda-42ef-b1d9-d1098c8eedf1
# ╟─b6633e09-0c8e-40a0-ab80-6820a2d4e334
# ╠═15f467b0-9f72-4132-b8e9-d5d21a39fb40
# ╟─a5fd87f4-f7ee-4517-9cc5-9f244a7c5b6c
# ╠═2e81c727-d8b4-4e15-996c-eb7cc5490b14
# ╠═89f3fb1e-c5c1-4fdc-9b49-69740705e42e
# ╠═b49eae6e-ba88-42f6-a79a-aa6162ef4fb6
# ╠═5c9939a1-c76b-4567-b812-b5b62738d195
# ╠═2ba54cc1-60bd-4d5a-a499-8b84b0047603
# ╠═7ddeb4e2-5264-452b-9014-2589d520905a
# ╠═1a65560b-5e71-4321-943f-ef39fc4c8da0
# ╠═73083757-7f01-4822-b8c6-cf1aa7c269b5
# ╠═bceb2a11-be3c-48d6-8837-26fbd3bc77ea
# ╠═e0f52e82-25f6-48df-9768-297c5ba93270
# ╠═f66a434b-a69f-4a08-a709-de71c1b8a47e
# ╠═b11af2cb-9908-4513-9e3c-d23839cb0dd4
# ╠═93916065-2494-4852-a039-8d28b7dd8084
# ╟─c161b3c3-55e9-4c0a-9fbf-c8e7fee076ac
# ╟─a923b951-a150-45a5-8a1b-5d4d6eb1466a
# ╠═1f181ebf-74a4-40aa-98c9-efe61422d825
# ╟─9e17da37-b8d9-4330-b4b9-dde01105e7ab
# ╟─4fd9c0f2-0315-4ff8-80af-2c7b5913dba8
# ╟─aced6467-82cd-44d3-a1fc-ee3195b32fe5
# ╟─807e74dc-c4be-44fa-8ae8-deef2d657608
# ╟─efd570d4-d7b4-4f97-bf48-1af06d398cbb
# ╟─29d32e07-d324-4e8e-866e-84b719be3b75
# ╟─4cf0d6da-37ae-453e-aacd-987e9b59830c
# ╟─0e777c99-e672-403d-acad-14b7e160f4de
# ╟─d9989bbd-72bc-44fa-a407-cd791ad160b2
# ╟─e1b3ba15-a5a7-45d9-88f8-e3f98b01c7d1
# ╟─54fb7b0e-5458-41c1-aa16-b6ea47033788
# ╠═e52cf867-1264-42c4-b8d4-029ba1e7be67
# ╟─f5d2be87-428e-4e98-aafb-5e37915dad50
# ╟─44d4ed9b-9327-433c-8056-226afc440136
# ╟─8e9d745f-09c0-426e-803f-d9bb8ca1ea2b
# ╟─bc48fb0e-f8ff-49f3-9a83-9e5c60874352
# ╟─de4b9a1d-d50b-4464-a12f-25f30bc15754
# ╟─7935ee56-38e6-48d4-ae9b-400c6acab27a
# ╟─dc97da7a-d3c7-484e-9c98-68b567a6a9e2
# ╟─77b3e8d5-3dcc-445d-b120-ec9f88d1ee93
# ╠═33219d81-8f7f-4b04-ab26-89d74b9324e6
# ╠═9c4bf868-1259-40a7-9506-be3295970e9c
# ╠═c46e9d35-86c9-4e8c-9979-b0fdd2356802
# ╠═b2f1d5fa-70ab-4922-bb61-d303c7cf616e
# ╠═3b9f7b15-7ce9-4d54-8649-4430e0ad3fd9
# ╠═47f4caab-fa4f-410a-833f-79367388b5a6
# ╠═80493ac0-ebe2-4cc7-988b-1cc85af602d9
# ╠═f489b38c-82a4-4b78-b128-b5cc1512bff8
# ╠═819cc8e0-36b1-4442-aabc-7d8b230d9fd9
# ╠═0cbfc5eb-58a0-4814-893e-2d7d4837d8b6
# ╟─d917888f-893a-42ac-8217-cc2d501307b6
# ╟─739810fa-61d8-4258-9fa2-a54f3d463c3a
# ╟─cdac8d4c-e4ac-4880-85ba-913ff89400ad
# ╟─9f93a288-2761-40d3-b045-c0fabb06d8fa
# ╟─ac251c58-4dab-4ef8-8ac5-7b1d3d36bb4d
# ╠═d4857ff6-42ad-4c2f-bc6b-b0590a0e83f6
# ╠═911257b1-a25e-448e-b785-682359513b27
# ╟─c6bb642b-43df-40f6-b3f9-dc3bf0d3fb79
# ╟─c770d6b9-74b1-49f7-81af-dd9456d27d1f
# ╟─843721c4-d5d0-42dd-91cb-212703b492fd
# ╠═2f4163b0-32d7-46f9-aa23-bd5d36026cd8
# ╠═550ac45b-d0a7-4fcc-b395-dccf4f289319
# ╟─1a682c5c-137a-48c0-b1bf-a9b0b8c113c2
# ╟─d07af222-5968-44c4-8de0-c21ec8ce417f
# ╟─66236dc8-f4f0-4427-92a0-70afb9f4fc29
# ╟─3b1ef34d-7f84-4c3e-a519-d5a4b36bb499
# ╟─feb966ce-8fb7-41c7-9f95-6449ae0ffb74
# ╟─12f69d23-bff9-4297-adc2-839150a09375
# ╟─de20d83d-2276-455c-b472-ed8e49030160
# ╠═e0a8cc52-ff50-4ad0-901f-88c634a6b66b
# ╠═63228e37-c463-41c8-9e98-9e93da95ad63
# ╟─2ccae8a3-1da0-4329-8f5c-ba9662f64ef3
# ╟─a9ed0b70-1fb3-4bfb-8d5c-cd55d14ddc27
# ╟─dbe3e527-0b59-45eb-842c-bff079e327d2
# ╟─4fad0eb0-6e82-46b4-9f72-7829efaf751f
# ╟─c37a8a6e-f9bd-47d5-aaaf-0939d15a51c6
# ╟─c9a6a696-6818-4ed5-ac87-028f764ad0f6
# ╟─d3894890-4b97-498d-9d9e-db29577caae9
# ╟─c56ce2b2-8fd2-427b-9d6e-26dbe0ce8799
# ╟─5a99e920-a278-4d20-8eed-ef3bb86ef7dd
# ╟─c50a7899-e586-4676-98b4-5910120a8177
# ╟─fa1683c2-cfab-426f-976f-6be38033d42f
# ╠═9f079605-3957-40ff-87cb-c616709431b2
# ╠═e471acb5-dea8-4326-9233-b73f2ee1fd3b
# ╠═f4a035d9-d598-4c08-bd83-f30d665b1581
# ╠═b069792c-d0da-49e3-83a7-9e79e771ae82
# ╠═9f2651e9-f5b9-4a40-9551-43942cd579ce
# ╠═dab79091-942c-4444-ae56-5a02f525b169
# ╠═bd4c3584-31a0-49d2-b32f-8153c8175b2e
# ╠═6bd61132-3a4b-4d6b-aa18-aded7dab3f7b
# ╠═e0db485e-9b23-4ac3-9d0a-0e7ee39f191c
# ╠═71546c45-d533-41a7-ab3d-5d4891e04400
# ╟─77ccf7b0-6743-4a9d-8a82-787dce694072
# ╟─86180b76-68c6-4916-9707-09fa0d34fc04
# ╟─01c9269b-3d64-4f3e-8746-29a5ac82f6c1
# ╟─f7b60c19-1080-45a3-ba37-356c25dd4756
# ╟─5ea85756-468b-403a-af48-1eb79bf9a45e
# ╟─dfe691aa-63b4-4718-9657-47a707ab7979
# ╟─a1587732-25ff-414c-a198-9a6552ca1e88
# ╟─5f27d9bf-4c05-41c1-8385-c0f739eb6abb
# ╟─9b936cbc-1a8f-466b-8b4a-1b9d9889d445
# ╟─1cebf21d-e330-4779-8659-21d637b10e92
# ╟─3815acad-7614-4a78-a8ff-b9a0580adb4d
# ╟─274b9059-cc44-4226-a4fd-a35e88dec084
# ╟─1c75d8be-7521-4cac-9ece-d03e2019e104
# ╟─03cfaa0b-8442-4969-9e98-660e71a468e9
# ╟─785601e7-0456-4b74-9730-325605ec923d
# ╟─2d2ba987-5a03-4530-9abe-cc5726eab943
# ╠═42d10eba-1284-497b-a720-b84389c6e37c
# ╠═34b21dd7-82b5-426e-a45c-ab4a50670ebc
# ╟─4f86c676-8819-418d-b467-bb65339e1b48
# ╟─5e50a684-d480-4a2e-83fb-4635f6c8bf12
# ╟─522a7064-995f-47d9-aba7-d8bc4c8ec26b
# ╟─8eed558f-942a-4613-9177-80a9b21628ec
# ╟─51f51bce-1352-4d60-8a3a-6ff0300172df
# ╟─acf02cec-247c-466f-b808-ca5956a84c37
# ╟─4a29319e-970f-4483-ac95-b7dbcf60d392
# ╟─03a0dad0-4eae-42a1-b48d-0c7653742109
# ╟─fde253e8-74d9-4439-a61d-97c450a0e6dd
# ╟─ac599ebb-b490-4fd8-b456-de6ccc715d73
# ╟─a2195ced-eab0-45bf-b0c9-0a4407af8f60
# ╠═4a1dbb5c-6f8d-449e-8b33-219d4407daf5
# ╠═ea1788c0-ff74-4a43-b0e2-c4f6b01bfe21
# ╠═594e0227-0c11-422a-9ee9-d44e3907a729
# ╠═d815bc19-ab79-4c3b-b33e-134373454244
# ╠═e17c7dd0-25b1-4fcf-a684-9982e33bc729
# ╠═1186a037-518e-4d0b-95f2-502dd55feddd
# ╠═9a7fc6f8-63f9-4133-9543-c81288f91bbd
# ╠═0cde4a0d-4f28-4201-ad91-274eed2abff2
# ╠═d34f0813-a5cc-4551-a4c7-e9b309fac679
# ╠═4376a1ce-8e9b-41fe-963c-27df205925f1
# ╠═ce58ea06-cc92-499c-a221-44267f1a63c9
# ╠═7963a153-e898-4c81-af8e-c7b18475f03f
# ╠═cb337784-7e49-4ebb-8014-674c9284a50a
# ╠═53e44268-c0c7-420c-8aec-8548289fb96c
# ╠═25dd78fc-9617-49c7-adff-83d1d1e8b618
# ╠═d1c8e68f-4ffc-4a9a-b200-7b84beb7c4da
