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
  SimpleDiGraph,
  add_edge!,
  all_neighbors,
  dst,
  edges,
  ne,
  neighbors,
  nv,
  src,
  vertices

using ITensors: data, QNIndex

export @visualize, visualize, itensornetwork

# Some general graph functionality
include("graphs.jl")

# Backends interface
include("backends/interface.jl")
include("defaults.jl")

# Conversion betweens graphs and ITensor networks
include("itensor_graph.jl")

# Visualizing ITensor networks
include("visualize_itensor.jl")
include("visualize_macro.jl")

# Backends
include("backends/UnicodePlots.jl")
include("backends/Makie.jl")

end
