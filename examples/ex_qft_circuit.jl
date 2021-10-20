using ITensors
using ITensorsVisualization
using Graphs
using GLMakie
using PastaQ: qft

include("utils/circuit_network.jl")

N = 4
gates = qft(N)

s = siteinds("Qubit", N)

U, s̃ = circuit_network(gates, s)
ψ = MPS(s)
ψ̃ = MPS(s̃)
tn = [ψ..., U..., ψ̃...]

original_backend = ITensorsVisualization.set_backend!("Makie")

@visualize fig tn arrow_show=true show_tags=true show_plevs=true edge_textsize=20 layout=layered_layout
@visualize! fig[1, 2] tn ndims=3 show_plevs=true edge_textsize=20

ITensorsVisualization.set_backend!(original_backend)

fig
