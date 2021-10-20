using ITensors
using ITensorsVisualization
using Graphs
using GLMakie
using PastaQ: randomcircuit

include("utils/circuit_network.jl")

using ITensorsVisualization: layered_layout

Nx, Ny = 3, 3
N = Nx * Ny
gates = randomcircuit(Nx, Ny, 4; twoqubitgates = "CX", onequbitgates = "Rn", layered = false, rotated=false)

s = siteinds("Qubit", N)

U, s̃ = circuit_network(gates, s)
ψ = MPS(s)
ψ̃ = MPS(s̃)
tn = [prod(ψ), U..., prod(ψ̃)]

original_backend = ITensorsVisualization.set_backend!("Makie")

@visualize fig tn arrow_show=true show_plevs=true layout=layered_layout edge_textsize=20
@visualize! fig[2, 1] tn ndims=3 arrow_show=true show_plevs=true edge_textsize=10

ITensorsVisualization.set_backend!(original_backend)

fig
