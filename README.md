# Coils.jl

Coils.jl is a Julia library that provides various types and functions to engineering magnetic coils for multiple applications.
The library aims to simplify designing, analyzing, and optimizing magnetic coils made of rectangular hollow core wire.
Users can specify the geometry, number of turns, and coil wire size, and the library will compute the resulting physical properties.

## Installation

```julia
using Pkg

Pkg.add("https://github.com/ryd-yb/Coils.jl")
```

## Usage

See the notebooks in `example`:

```julia
using Pkg

Pkg.activate(".")
Pkg.instantiate()

using Pluto

Pluto.run()
```