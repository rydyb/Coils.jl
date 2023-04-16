var documenterSearchIndex = {"docs":
[{"location":"api/coil/#Coil","page":"Coil","title":"Coil","text":"","category":"section"},{"location":"api/coil/","page":"Coil","title":"Coil","text":"Coils.Coil","category":"page"},{"location":"api/coil/#Coils.Coil","page":"Coil","title":"Coils.Coil","text":"Coil\n\nAn abstract type for a magnetic coil.\n\n\n\n\n\n","category":"type"},{"location":"api/coil/","page":"Coil","title":"Coil","text":"Coils.mfd","category":"page"},{"location":"api/coil/#Coils.mfd","page":"Coil","title":"Coils.mfd","text":"mfd(c::Coil, ρ, z)\n\nComputes the radial and axial magnetic flux density due to a current flowing through a coil.\n\nArguments\n\nc::Coil: A specific coil.\nρ::Unitful.Length: The radial distance from the center of the coil.\nz::Unitful.Length: The axial distance from the center of the coil.\n\nReturns\n\nBρ::Unitful.MagneticFluxDensity: The radial magnetic flux density.\n\n\n\n\n\n","category":"function"},{"location":"api/coil/","page":"Coil","title":"Coil","text":"Coils.mfdz","category":"page"},{"location":"api/coil/#Coils.mfdz","page":"Coil","title":"Coils.mfdz","text":"mfdz(c::Coil[, z])\n\nComputes the axial magnetic flux density along the longitudinal axis due to a current flowing through a coil.\n\nUsually, you want to use mfd to compute the magnetic flux density at a given point. However, for some coil configurations simplified formulas for the axial magnetic flux density exist, which can be compared with mfd as a safety check.\n\nArguments\n\nc::Coil: The coil.\nz::Unitful.Length: The axial coordinate by default equal to the height of the coil c.\n\nReturns\n\nBz::Unitful.MagneticFluxDensity: The axial magnetic flux density.\n\n\n\n\n\n","category":"function"},{"location":"api/coil/","page":"Coil","title":"Coil","text":"Coils.conductor_coordinates","category":"page"},{"location":"api/coil/#Coils.conductor_coordinates","page":"Coil","title":"Coils.conductor_coordinates","text":"conductor_coordinates(c::Coil)\n\nReturns the coordinates of the conductor in cylindrical coordinates.\n\nArguments\n\nc::Coil: A specific coil.\n\nReturns\n\ncoordinates::Vector{Vector{Unitful.Length}}: The coordinates of the conductor.\n\n\n\n\n\n","category":"function"},{"location":"api/coil/","page":"Coil","title":"Coil","text":"Coils.conductor_length","category":"page"},{"location":"api/coil/#Coils.conductor_length","page":"Coil","title":"Coils.conductor_length","text":"conductor_length(c::Coil)\n\nReturns the total length of the conductor.\n\nArguments\n\nc::Coil: A specific coil.\n\nReturns\n\nlength::Unitful.Length: The length of the conductor.\n\n\n\n\n\n","category":"function"},{"location":"api/current_loops/#CurrentLoops","page":"CurrentLoops","title":"CurrentLoops","text":"","category":"section"},{"location":"api/current_loops/","page":"CurrentLoops","title":"CurrentLoops","text":"Converts a coil to a vector of current loops.","category":"page"},{"location":"api/current_loops/","page":"CurrentLoops","title":"CurrentLoops","text":"Coils.CurrentLoops","category":"page"},{"location":"api/current_loops/#Coils.CurrentLoops","page":"CurrentLoops","title":"Coils.CurrentLoops","text":"CurrentLoops(c::Helical)\n\nCreates an array of CurrentLoops approximating a Helical coil.\n\nArguments\n\nc::Helical: The helical coil to mimic.\n\nReturn\n\nVector{CurrentLoop}: An array of CurrentLoops.\n\n\n\n\n\nCurrentLoops(c::Helmholtz)\n\nCreates an array of CurrentLoops approximating a(n) (anti-)Helmholtz configuration of Helical coils.\n\nArguments\n\nc::Helmholtz: The (anti-)Helmholtz coil.\n\nReturn\n\nVector{CurrentLoop}: An array of CurrentLoops.\n\n\n\n\n\n","category":"function"},{"location":"api/current_loops/","page":"CurrentLoops","title":"CurrentLoops","text":"Coils.conductor_coordinates","category":"page"},{"location":"api/current_loops/","page":"CurrentLoops","title":"CurrentLoops","text":"Coils.conductor_length","category":"page"},{"location":"api/current_loops/","page":"CurrentLoops","title":"CurrentLoops","text":"Coils.mfd","category":"page"},{"location":"api/current_loop/#CurrentLoop","page":"CurrentLoop","title":"CurrentLoop","text":"","category":"section"},{"location":"api/current_loop/","page":"CurrentLoop","title":"CurrentLoop","text":"Coils.CurrentLoop","category":"page"},{"location":"api/current_loop/#Coils.CurrentLoop","page":"CurrentLoop","title":"Coils.CurrentLoop","text":"CurrentLoop(; current::Unitful.Current, radius::Unitful.Length, height::Unitful.Length = 0u\"m\")\n\nA circular current CurrentLoop.\n\nKeywords\n\ncurrent::Unitful.Current: The current running through the loop.\nradius::Unitful.Length: The radius of the current loop.\nheight::Unitful.Length: The height of the current loop, zero by default.\n\n\n\n\n\n","category":"type"},{"location":"api/current_loop/","page":"CurrentLoop","title":"CurrentLoop","text":"Coils.mfd(c::CurrentLoop, ρ, z)","category":"page"},{"location":"api/current_loop/#Coils.mfd-Tuple{CurrentLoop, Any, Any}","page":"CurrentLoop","title":"Coils.mfd","text":"mfd(c::CurrentLoop, ρ, z)\n\nComputes the magnetic flux density according to analytical solution to the Biot-Savart law, see [1] and [2].\n\n[1]: Simpson, James C. et al. “Simple Analytic Expressions for the Magnetic Field of a Circular Current Loop.” (2001).\n[2]: Jang, Taehun, et al. \"Off-axis magnetic fields of a circular loop and a solenoid for the electromagnetic induction of a magnetic pendulum.\"\n\nArguments\n\nc::CurrentLoop: The CurrentLoop.\nρ::Unitful.Length: The radial coordinate.\nz::Unitful.Length: The axial coordinate.\n\nReturns\n\nVector{Unitful.MagneticFluxDensity}: The radial and axial magnetic flux density components.\n\n\n\n\n\n","category":"method"},{"location":"api/current_loop/","page":"CurrentLoop","title":"CurrentLoop","text":"Coils.mfdz(c::CurrentLoop, z)","category":"page"},{"location":"api/current_loop/#Coils.mfdz-Tuple{CurrentLoop, Any}","page":"CurrentLoop","title":"Coils.mfdz","text":"mfdz(c::CurrentLoop[, z])\n\nComputes the magnetic flux density along the z-axis according to [1].\n\n[1]: https://de.wikipedia.org/wiki/Leiterschleife\n\nArguments\n\nc::CurrentLoop: The CurrentLoop.\nz::Unitful.Length: The axial coordinate by default equal to the height of current loop c.\n\nReturns\n\nVector{Unitful.MagneticFluxDensity}: The radial and axial magnetic flux density components.\n\n\n\n\n\n","category":"method"},{"location":"api/helical/#Helical","page":"Helical","title":"Helical","text":"","category":"section"},{"location":"api/helical/","page":"Helical","title":"Helical","text":"Coils.Helical","category":"page"},{"location":"api/helical/#Coils.Helical","page":"Helical","title":"Coils.Helical","text":"Helical(; current, inner_radius, outer_radius, length, height, turns)\n\nA helical coil with turns in radial and axial directions.\n\nFields\n\ncurrent::Unitful.Current: The current in the coil.\ninner_radius::Unitful.Length: The inner radius of the coil.\nouter_radius::Unitful.Length: The outer radius of the coil.\nlength::Unitful.Length: The (axial) length of the coil.\nheight::Unitful.Length: The height or axial offset of the coil.\nradial_turns::Unsigned: The number of turns in the radial direction.\naxial_turns::Unsigned: The number of turns in the axial direction.\n\n\n\n\n\n","category":"type"},{"location":"api/helical/","page":"Helical","title":"Helical","text":"Coils.Pancake","category":"page"},{"location":"api/helical/#Coils.Pancake","page":"Helical","title":"Coils.Pancake","text":"Pancake(; current, inner_radius, outer_radius, turns, height)\n\nA pancake coil which has only turns in the radial direction.\n\nKeywords\n\ncurrent::Unitful.Current: The current in the coil.\ninner_radius::Unitful.Length: The inner radius of the coil.\nouter_radius::Unitful.Length: The outer radius of the coil.\nturns::Unsigned: The number of turns in the radial direction.\nheight::Unitful.Length: The height or axial offset of the coil.\n\nReturn\n\nHelical: A helical coil with only radial turns.\n\n\n\n\n\n","category":"function"},{"location":"api/helical/","page":"Helical","title":"Helical","text":"Coils.Solenoid","category":"page"},{"location":"api/helical/#Coils.Solenoid","page":"Helical","title":"Coils.Solenoid","text":"Solenoid(; current, radius, length, turns, height)\n\nA solenoid coil which has only turns in the axial direction.\n\nKeywords\n\ncurrent::Unitful.Current: The current in the coil.\nradius::Unitful.Length: The radius of the coil.\nlength::Unitful.Length: The (axial) length of the coil.\nturns::Unsigned: The number of turns in the axial direction.\nheight::Unitful.Length: The height or axial offset of the coil.\n\nReturn\n\nHelical: A helical coil with only axial turns.\n\n\n\n\n\n","category":"function"},{"location":"api/helical/","page":"Helical","title":"Helical","text":"Coils.mfdz(c::Helical)","category":"page"},{"location":"api/helical/#Coils.mfdz-Tuple{Helical}","page":"Helical","title":"Coils.mfdz","text":"mfdz(c::Helical)\n\nComputes the magnetic flux density for an infinite-length solenoid according to [1].\n\n[1]: https://en.wikipedia.org/wiki/Solenoid\n\nArguments\n\nc::Helical: The solenoid.\n\nReturns\n\nVector{Unitful.MagneticFluxDensity}: The radial and axial magnetic flux density components.\n\n\n\n\n\n","category":"method"},{"location":"#Coils.jl","page":"Coils.jl","title":"Coils.jl","text":"","category":"section"},{"location":"","page":"Coils.jl","title":"Coils.jl","text":"Coils.jl is a Julia library that provides various types and functions for engineering magnetic coils.","category":"page"},{"location":"#Installation","page":"Coils.jl","title":"Installation","text":"","category":"section"},{"location":"","page":"Coils.jl","title":"Coils.jl","text":"using Pkg; Pkg.add(\"Coils\")","category":"page"},{"location":"api/helmholtz/#Helmholtz","page":"Helmholtz","title":"Helmholtz","text":"","category":"section"},{"location":"api/helmholtz/","page":"Helmholtz","title":"Helmholtz","text":"Coils.Helmholtz","category":"page"},{"location":"api/helmholtz/#Coils.Helmholtz","page":"Helmholtz","title":"Coils.Helmholtz","text":"Helmholtz(; coil::Helical, separation::Unitful.Length = (coil.outer_radius + coil.inner_radius) / 2)\nAntiHelmholtz(; coil::Helical, separation::Unitful.Length = √3 * (coil.outer_radius + coil.inner_radius) / 2\n\nA(n) (anti-)Helmholtz coil configuration of Helical coils.\n\nKeywords\n\ncoil::Helical: The Helical coil configuration.\nseparation::Unitful.Length: The separation between the coils by default uses the ideal separation.\n\n\n\n\n\n","category":"type"},{"location":"api/helmholtz/","page":"Helmholtz","title":"Helmholtz","text":"Coils.AntiHelmholtz","category":"page"},{"location":"api/helmholtz/","page":"Helmholtz","title":"Helmholtz","text":"Coils.inductance(c::Helmholtz)","category":"page"},{"location":"api/helmholtz/#Coils.inductance-Tuple{Helmholtz}","page":"Helmholtz","title":"Coils.inductance","text":"inductance(c::Helmholtz)\n\nReturns the approximate inductance of the (anti-)Helmholtz coil according to Ref. [1]\n\n[1]: https://de.wikipedia.org/wiki/Helmholtz-Spule#Induktivit%C3%A4t\n\nArguments\n\nc::Helmholtz: The (anti-)Helmholtz coil.\n\nReturns\n\nUnitful.Inductance: The inductance of the (anti-)Helmholtz coil.\n\n\n\n\n\n","category":"method"},{"location":"api/helmholtz/","page":"Helmholtz","title":"Helmholtz","text":"Coils.mfdz(c::Helmholtz)","category":"page"},{"location":"api/helmholtz/#Coils.mfdz-Tuple{Helmholtz}","page":"Helmholtz","title":"Coils.mfdz","text":"mfdz(c::Helmholtz)\n\nComputes the magnetic flux density at the center of an infinite-length (anti-)Helmholtz coil according to [1].\n\n[1]: https://en.wikipedia.org/wiki/Helmholtz_coil\n\nWe use the formula of an infinite-length solenoid where we use the product of radial and axial turns as the number of turns.\n\nArguments\n\nc::Helmholtz: The (anti-)Helmholtz coil.\n\nReturns\n\nVector{Unitful.MagneticFluxDensity}: The radial and axial magnetic flux density components.\n\n\n\n\n\n","category":"method"}]
}