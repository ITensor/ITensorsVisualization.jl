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
# TODO: use Requires to make optional
using UnicodePlots: UnicodePlots
include("visualize/backends/interface.jl")
include("visualize/backends/UnicodePlots.jl")

export @visualize, visualize

# UnicodePlots backend
include("visualize/visualize_graph.jl")
include("visualize/itensor_graph.jl")
include("visualize/visualize_itensor.jl")

# Makie backend
using GLMakie
include("Makie/utils.jl")
include("Makie/visualize_tensornetwork.jl")
include("Makie/visualize_macro.jl")

end
