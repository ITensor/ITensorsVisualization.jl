module ITensorsVisualization

using ITensors
using AbstractTrees
using Colors
using GeometryBasics
using MetaGraphs
using LayeredLayouts
using LinearAlgebra
using NetworkLayout
using SparseArrays
using Statistics

# Avoid conflict with `ITensors.contract`
# (Graphs also exports `contract`).
using Graphs:
  Graphs,
  AbstractEdge,
  AbstractGraph,
  SimpleGraph,
  SimpleDiGraph,
  add_edge!,
  add_vertex!,
  all_neighbors,
  dst,
  edges,
  ne,
  neighbors,
  nv,
  src,
  vertices

using ITensors: data, QNIndex

export
  @visualize,
  @visualize!,
  @visualize_noeval,
  @visualize_noeval!,
  @visualize_sequence,
  itensornetwork

# Some general graph functionality
include("layered_layout.jl")
include("graphs.jl")

# Backends interface
include("backends/interface.jl")
include("defaults.jl")

# Conversion betweens graphs and ITensor networks
include("itensor_graph.jl")

# Visualizing ITensor networks
include("visualize_macro.jl")

# Backends
include("backends/UnicodePlots.jl")
include("backends/Makie.jl")

end
