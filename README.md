# Coils.jl

| **Build Status**                          | **Code Coverage**               |
|:-----------------------------------------:|:-------------------------------:|
| [![][CI-img]][CI-url] | [![][codecov-img]][codecov-url] |

Coils.jl is a Julia library that provides various types and functions for engineering magnetic coils made of rectangular hollow core wire.

## Installation

Coils.jl is a registered package and you can install it over the REPL:
```julia
julia> ]add Coils
```

## Usage
See the notebooks in [example](examples/). Clone or download those files. You can run them with [Pluto.jl](https://github.com/fonsp/Pluto.jl). Execute the following in the REPL:
```julia
julia> using Pluto

julia> Pluto.run()
```


[CI-img]: https://github.com/rydyb/Coils.jl/actions/workflows/ci.yml/badge.svg
[CI-url]: https://github.com/rydyb/Coils.jl/actions/workflows/ci.yml

[codecov-img]:  https://codecov.io/gh/rydyb/Coils.jl/branch/main/graph/badge.svg?token=CNF55N4HDZ
[codecov-url]: https://codecov.io/gh/rydyb/Coils.jl
