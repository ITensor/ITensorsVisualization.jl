module ITensorsVisualization

using ITensors
using LightGraphs
using MetaGraphs
using LinearAlgebra
using NetworkLayout
using SparseArrays
using Statistics

using ITensors: data

export @visualize, visualize, itensornetwork

# Backends
include("backends/interface.jl")

using UnicodePlots: UnicodePlots
include("backends/UnicodePlots.jl")

using GRUtils: GRUtils
include("backends/GR.jl")

using Plots: Plots
include("backends/Plots.jl")

# Makie backend
using GLMakie
using Makie
using GraphMakie
include("backends/Makie.jl")
# UnicodePlots backend
include("visualize_graph.jl")
include("itensor_graph.jl")
include("visualize_itensor.jl")
include("visualize_macro.jl")

end
