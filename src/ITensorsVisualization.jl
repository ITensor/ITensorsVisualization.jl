module ITensorsVisualization

using ITensors
using LightGraphs
using MetaGraphs
using LinearAlgebra
using NetworkLayout
using SparseArrays
using Statistics

using ITensors: data

# Backends
using GLMakie
using UnicodePlots

export @visualize, visualize

# Makie backend
include("Makie/utils.jl")
include("Makie/visualize_tensornetwork.jl")
include("Makie/visualize_macro.jl")

# UnicodePlots backend
include("visualize/visualize_graph.jl")
include("visualize/itensor_graph.jl")
include("visualize/visualize_itensor.jl")

end
