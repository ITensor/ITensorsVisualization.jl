
const continues = ["c", "Continue", "C", "continue"]

function c_to_continue()
  while true
    println("Press C/c and then Enter to continue:")
    ans = readline()
    ans ∈ continues && return
  end
end

# Visualize a contraction and then perform the contraction
function contract_visualize(As::ITensor...; pause = false, kwargs...)
  scene = visualize_tensornetwork(As...; kwargs...)
  display(scene)
  if pause
    c_to_continue()
  end
  return *(As...)
end

expr_to_string(s::Symbol) = String(s)
expr_to_string(ex::Expr) = String(repr(ex))[3:end-1]

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
ABC = @visualize AB * C names = ["AB = A*B", "C"]
```

# Keyword arguments:
- `pause::Bool = false`: pause after displaying the tensor network visualization.
- `showtags::Bool = true`: show the Index tags on the edge labels of the network.
- `showplevs::Bool = true`: show the Index prime levels on the edge labels of the network.
- `showids::Bool = true`: show a shortened version of the Index id numbers in the edge labels of the network.
- `showdims::Bool = true`: show the Index dimensions on the edge labels of the network.
- `showqns::Bool = false`: show the quantum number 
- `showarrows::Bool = all(hasqns, tensors)`: show the arrow directions on the edges of the network which correspond to the Index directions for QN indices (corresponding to contravariant and covariant spaces).
- `names::Vector{String}`: custom names to display for the tensors in the digram. If not specified, they are determined automatically from the input to the macro.
"""
macro visualize(ex, kwargs...)
  # Must be a tensor contraction
  @assert ex.args[1] == :*
  expr_kwargs = [esc(a) for a in kwargs]
  res = if any(arg -> arg.args[1].args[1] == :names, expr_kwargs)
    # If names was passed, don't automatically generate the names
    :(contract_visualize($(esc.(ex.args[2:end])...); $(expr_kwargs...)))
  else
    # names was not passed, automatically generate them from the macro input
    :(contract_visualize($(esc.(ex.args[2:end])...); $(expr_kwargs...), names = expr_to_string.($(ex.args[2:end]))))
  end
  return res
end

