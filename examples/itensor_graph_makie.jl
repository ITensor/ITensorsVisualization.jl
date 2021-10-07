using ITensors
using ITensorsVisualization
using LightGraphs
using GLMakie

ITensorsVisualization.set_backend!("Makie")

g = grid((5,))
tn = itensornetwork(g; linkspaces=10, sitespaces=2)
@visualize tn
