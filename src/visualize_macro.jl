function visualize(g::AbstractGraph; backend=get_backend(), kwargs...)
  return visualize(Backend(backend), g; kwargs...)
end

function visualize(tn::Vector{ITensor}; kwargs...)
  return visualize(MetaDiGraph(tn); kwargs...)
end
visualize(ψ::MPS; kwargs...) = visualize(data(ψ); kwargs...)
visualize(tn::Tuple{Vararg{ITensor}}; kwargs...) = visualize(collect(tn); kwargs...)
visualize(tn::ITensor...; kwargs...) = visualize(collect(tn); kwargs...)

function visualize!(fig, g::AbstractGraph; backend=get_backend(), kwargs...)
  return visualize!(Backend(backend), fig, g; kwargs...)
end

function visualize!(fig, tn::Vector{ITensor}; kwargs...)
  return visualize!(fig, MetaDiGraph(tn); kwargs...)
end
visualize!(fig, ψ::MPS; kwargs...) = visualize!(fig, data(ψ); kwargs...)
visualize!(fig, tn::Tuple{Vararg{ITensor}}; kwargs...) = visualize!(fig, collect(tn); kwargs...)
visualize!(fig, tn::ITensor...; kwargs...) = visualize!(fig, collect(tn); kwargs...)

function visualize(f::Union{Function,Type}, As...; kwargs...)
  # TODO: specialize of the function type. Also accept a general collection.
  return visualize(As...; kwargs...)
end

function visualize!(fig, f::Union{Function,Type}, As...; kwargs...)
  # TODO: specialize of the function type. Also accept a general collection.
  return visualize!(fig, As...; kwargs...)
end

expr_to_string(s::Symbol) = String(s)
expr_to_string(ex::Expr) = String(repr(ex))[3:(end - 1)]

function visualize_symbol(ex::Symbol, kwargs::Expr...)
  e = quote
    visualize(identity, $(esc(ex)); visualize_macro_vertex_labels_prefix=$(Expr(:quote, ex)), $(esc.(kwargs)...))
  end
  return e
end

function visualize_symbol!(fig, ex::Symbol, kwargs::Expr...)
  e = quote
    visualize!($(esc(fig)), identity, $(esc(ex)); visualize_macro_vertex_labels_prefix=$(Expr(:quote, ex)), $(esc.(kwargs)...))
  end
  return e
end

function visualize_expr(ex::Expr, kwargs::Expr...)
  if ex.head == :call
    # For inputs like `A * B`
    e = quote
      visualize($(first(ex.args)), $(esc.(ex.args[2:end])...); visualize_macro_vertex_labels=$(expr_to_string.(ex.args[2:end])), $(esc.(kwargs)...))
    end
  elseif ex.head == :vect
    # For inputs like `[A, B]`
    e = quote
      visualize(collect, $(esc.(ex.args)...); visualize_macro_vertex_labels=$(expr_to_string.(ex.args)), $(esc.(kwargs)...))
    end
  else
    error("Visualizing expression $ex not supported.")
  end
  return e
end

function visualize_expr!(fig, ex::Expr, kwargs::Expr...)
  if ex.head == :call
    # For inputs like `A * B`
    e = quote
      visualize!($(esc(fig)), $(first(ex.args)), $(esc.(ex.args[2:end])...); visualize_macro_vertex_labels=$(expr_to_string.(ex.args[2:end])), $(esc.(kwargs)...))
    end
  elseif ex.head == :vect
    # For inputs like `[A, B]`
    e = quote
      visualize!($(esc(fig)), collect, $(esc.(ex.args)...); visualize_macro_vertex_labels=$(expr_to_string.(ex.args)), $(esc.(kwargs)...))
    end
  else
    error("Visualizing expression $ex not supported.")
  end
  return e
end

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

AB = @visualize A * B
# Use readline() to pause between plots
readline()
ABC = @visualize AB * C vertex=(labels = ["A*B", "C"],)
readline()

# Save the results to figures for viewing later
AB = @visualize fig1 A * B
ABC = @visualize fig2 AB * C vertex=(labels = ["A*B", "C"],)

display(fig1)
readline()
display(fig2)
readline()
```

# Keyword arguments:
- `show = (dims=true, tags=false, plevs=false, ids=false, qns=false, arrows=auto)`: show various properties of an Index on the edges of the graph visualization.
- `vertex = (labels=auto,)`: custom tensor labels to display on the vertices of the digram. If not specified, they are determined automatically from the input to the macro.
"""
macro visualize(fig::Symbol, ex::Symbol, kwargs::Expr...)
  e = quote
    $(esc(fig)) = $(visualize_symbol(ex, kwargs...))
    $(esc(ex))
  end
  return e
end

macro visualize!(fig, ex::Symbol, kwargs::Expr...)
  e = quote
    $(visualize_symbol!(fig, ex, kwargs...))
    $(esc(ex))
  end
  return e
end

macro visualize(ex::Symbol)
  e = quote
    display($(visualize_symbol(ex)))
    $(esc(ex))
  end
  return e
end

macro visualize(ex_or_fig::Symbol, ex_or_kwarg::Expr, last_kwargs::Expr...)
  if ex_or_kwarg.head == :(=)
    # The first input is the collection to visualize (no figure output binding specified)
    ex = ex_or_fig
    kwargs = (ex_or_kwarg, last_kwargs...)
    e = quote
      display($(visualize_symbol(ex, kwargs...)))
      $(esc(ex))
    end
  else
    # The first input is the binding for the figure output, the second is the expression
    # to visualize
    fig = ex_or_fig
    ex = ex_or_kwarg
    kwargs = last_kwargs
    e = quote
      $(esc(fig)) = $(visualize_expr(ex, kwargs...))
      $(esc(ex))
    end
  end
  return e
end

macro visualize!(fig, ex::Expr, kwargs::Expr...)
  e = quote
    $(visualize_expr!(fig, ex, kwargs...))
    $(esc(ex))
  end
  return e
end

macro visualize(ex::Expr, kwargs::Expr...)
  e = quote
    display($(visualize_expr(ex, kwargs...)))
    $(esc(ex))
  end
  return e
end

macro visualize_noeval(ex::Symbol, kwargs::Expr...)
  e = quote
    $(visualize_symbol(ex, kwargs...))
  end
  return e
end

macro visualize_noeval(ex::Expr, kwargs::Expr...)
  e = quote
    $(visualize_expr(ex, kwargs...))
  end
  return e
end

macro visualize_noeval!(fig, ex::Symbol, kwargs::Expr...)
  e = quote
    $(visualize_symbol!(fig, ex, kwargs...))
  end
  return e
end

macro visualize_noeval!(fig, ex::Expr, kwargs::Expr...)
  e = quote
    $(visualize_expr!(fig, ex, kwargs...))
  end
  return e
end
