const continues = ["c", "Continue", "C", "continue"]

function c_to_continue()
  while true
    println("Press C/c and then Enter to continue:")
    ans = readline()
    ans ∈ continues && return nothing
  end
end

function visualize(f::Union{Function,Type}, As...; execute=true, pause=false, kwargs...)
  scene = visualize(As...; kwargs...)
  display(scene)
  if pause
    c_to_continue()
  end
  if execute
    return f(As...)
  end
  return nothing
end

expr_to_string(s::Symbol) = String(s)
expr_to_string(ex::Expr) = String(repr(ex))[3:(end - 1)]

"""
    @visualize

Visualize a contraction of ITensors, returning the result of the contraction.

The contraction should be written in terms of a series of ITensors contracted with `*`.

# Examples
```julia
using ITensors
using ITensorsVisualization

i = Index(2, "index_i")
j = Index(10, "index_j")
k = Index(40, "index_k")
l = Index(40, "index_l")
m = Index(40, "index_m")
A = randomITensor(i, j, k)
B = randomITensor(i, j, l, m)
C = randomITensor(k, l)

# Contract the tensors over the common indices
# and visualize the results
ABC = @visualize A * B * C

# Pause to display intermediate results
AB = @visualize A * B pause = true
ABC = @visualize AB * C labels = ["A*B", "C"]
```

# Keyword arguments:
- `pause::Bool = false`: pause after displaying the tensor network visualization.
- `showtags::Bool = true`: show the Index tags on the edge labels of the network.
- `showplevs::Bool = true`: show the Index prime levels on the edge labels of the network.
- `showids::Bool = true`: show a shortened version of the Index id numbers in the edge labels of the network.
- `showdims::Bool = true`: show the Index dimensions on the edge labels of the network.
- `showqns::Bool = false`: show the quantum number sectors. Only available for ITensors with QNs.
- `showarrows::Bool = all(hasqns, tensors)`: show the arrow directions on the edges of the network which correspond to the Index directions for QN indices (corresponding to contravariant and covariant spaces). Only well defined for ITensors with QNs.
- `labels::Vector{String}`: custom tensor labels to display on the nodes of the digram. If not specified, they are determined automatically from the input to the macro.
"""
macro visualize(ex::Symbol, kwargs...)
  ex_res = quote
    visualize($(ex); vertex=(labels_prefix=$(Expr(:quote, ex)),), $(kwargs...))
  end
  return esc(ex_res)
end

macro visualize(ex::Expr, kwargs...)
  ex_res = :(visualize($(first(ex.args)), $(esc.(ex.args[2:end])...); visualize_macro_vertex_labels=expr_to_string.($(ex.args[2:end])), $(esc.(kwargs)...)))
  return ex_res
end
