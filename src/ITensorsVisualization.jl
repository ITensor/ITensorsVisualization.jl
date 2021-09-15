module ITensorsVisualization

using ITensors
using LightGraphs
using MetaGraphs
using LinearAlgebra
using NetworkLayout
using SparseArrays
using Statistics

# Backends
using GLMakie
using UnicodePlots

export @visualize, visualize

include("Makie/utils.jl")
include("Makie/visualize_tensornetwork.jl")
include("Makie/visualize_macro.jl")
include("visualize/visualize_graph.jl")

end
