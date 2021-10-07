using ITensors
using ITensorsVisualization
using LightGraphs
using GLMakie
using PastaQ: qft

include("utils/circuit_network.jl")

ITensorsVisualization.set_backend!("Makie")

N = 4
gates = qft(N)

s = siteinds("Qubit", N)

U, s̃ = circuit_network(gates, s)
ψ = MPS(s)
ψ̃ = MPS(s̃)
tn = [ψ..., U..., ψ̃...]

@visualize tn show=(arrows=true, tags=true, plevs=true) layout=layered_layout edge_labels_textsize=20
#@visualize tn ndims=3 show=(arrows=true, tags=true, plevs=true) edge_labels_textsize=20
#@visualize tn backend="UnicodePlots" show=(dims=false,) layout=layered_layout
