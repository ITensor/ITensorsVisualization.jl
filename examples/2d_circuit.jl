using ITensors
using ITensorsVisualization
using LightGraphs
using GLMakie
using PastaQ: randomcircuit

include("utils/circuit_network.jl")

ITensorsVisualization.set_backend!("Makie")

Nx, Ny = 3, 3
N = Nx * Ny
gates = randomcircuit(Nx, Ny, 4; twoqubitgates = "CX", onequbitgates = "Rn", layered = false, rotated=false)

s = siteinds("Qubit", N)

U, s̃ = circuit_network(gates, s)
ψ = MPS(s)
ψ̃ = MPS(s̃)
tn = [prod(ψ), U..., prod(ψ̃)]

#@visualize tn show=(arrows=true, plevs=true) layout=layered_layout edge_labels_textsize=20
@visualize tn ndims=3 show=(arrows=true, plevs=true) edge_labels_textsize=10
#@visualize tn backend="UnicodePlots" show=(dims=false,) layout=layered_layout
