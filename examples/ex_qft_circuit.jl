using ITensors
using ITensorsVisualization
using LightGraphs
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

@visualize fig1 tn show=(arrows=true, tags=true, plevs=true) layout=layered_layout edge=(textsize=20,)
@visualize fig2 tn ndims=3 show=(arrows=true, tags=true, plevs=true) edge=(textsize=20,)
@visualize fig3 tn backend="UnicodePlots" show=(dims=false,) layout=layered_layout

ITensorsVisualization.set_backend!(original_backend)

fig1, fig2, fig3
