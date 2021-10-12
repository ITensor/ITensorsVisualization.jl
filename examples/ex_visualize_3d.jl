using ITensors
using ITensorsVisualization
using GLMakie
using LightGraphs

tn = itensornetwork(Grid((3, 3, 3)))
@visualize fig tn ndims=3 show=(dims=false,) vertex=(size=400,) backend="Makie"

fig
