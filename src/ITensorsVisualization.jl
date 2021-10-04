module ITensorsVisualization

using ITensors
using Colors
using GeometryBasics
using MetaGraphs
using LinearAlgebra
using NetworkLayout
using SparseArrays
using Statistics

# Avoid conflict with `ITensors.contract`
# (LightGraphs also exports `contract).
using LightGraphs:
  LightGraphs,
  AbstractEdge,
  AbstractGraph,
  SimpleGraph,
  add_edge!,
  dst,
  edges,
  ne,
  neighbors,
  nv,
  src,
  vertices

using ITensors: data

export @visualize, visualize, itensornetwork

# Backends interface
include("backends/interface.jl")

include("visualize_graph.jl")
include("itensor_graph.jl")
include("visualize_itensor.jl")
include("visualize_macro.jl")

# Backends
include("backends/UnicodePlots.jl")
include("backends/Makie.jl")

end
