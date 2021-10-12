using ITensors
using ITensorsVisualization
using LightGraphs
using GLMakie
using PastaQ: randomcircuit

include("utils/circuit_network.jl")

Nx, Ny = 3, 3
N = Nx * Ny
gates = randomcircuit(Nx, Ny, 4; twoqubitgates = "CX", onequbitgates = "Rn", layered = false, rotated=false)

s = siteinds("Qubit", N)

U, s̃ = circuit_network(gates, s)
ψ = MPS(s)
ψ̃ = MPS(s̃)
tn = [prod(ψ), U..., prod(ψ̃)]

original_backend = ITensorsVisualization.set_backend!("Makie")

@visualize fig1 tn show=(arrows=true, plevs=true) layout=layered_layout edge=(textsize=20,)
@visualize fig2 tn ndims=3 show=(arrows=true, plevs=true) edge=(textsize=10,)
@visualize fig3 tn backend="UnicodePlots" show=(dims=false,) layout=layered_layout

ITensorsVisualization.set_backend!(original_backend)

fig1, fig2, fig3
