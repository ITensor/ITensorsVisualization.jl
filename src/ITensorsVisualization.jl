module ITensorsVisualization

using ITensors
using LightGraphs
using MetaGraphs
using LinearAlgebra
using NetworkLayout
using SparseArrays
using Statistics

using ITensors: data

export @visualize, visualize

# Backends
include("visualize/backends/interface.jl")

using UnicodePlots: UnicodePlots
include("visualize/backends/UnicodePlots.jl")

using GRUtils: GRUtils
include("visualize/backends/GR.jl")

using Plots: Plots
include("visualize/backends/Plots.jl")

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
