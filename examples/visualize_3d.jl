using ITensors
using ITensorsVisualization
using GLMakie

ITensorsVisualization.set_backend!("Makie")

tn = itensornetwork(Grid((3, 3, 3)))
@visualize tn ndims=3 show=(dims=false,) vertex=(size=400,)
