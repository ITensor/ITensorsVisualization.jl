function label_string(i::Index; show_tags=false)
  str = ""
  str *= string("(", dim(i))
  if show_tags
    str *= string("|", tags(i))
  end
  str *= ")"
  return str
end

function label_string(is; is_self_loop=false)
  str = is_self_loop ? "s" : "l"
  for n in eachindex(is)
    str *= label_string(is[n])
    if n ≠ lastindex(is)
      str *= "⊗"
    end
  end
  return str
end

function default_vertex_labels(r::AbstractRange)
  return ["T$n" for n in r]
end
default_vertex_labels(g::AbstractGraph) = default_vertex_labels(vertices(g))
default_vertex_labels(tn::AbstractArray{ITensor}) = default_vertex_labels(eachindex(tn))

default_label_key() = :label

function set_labels!(g::AbstractGraph; label_key, vertex_labels)
  for e in edges(g)
    # This includes self-loops
    indsₑ = get_prop(g, e, :inds)
    set_prop!(g, e, label_key, label_string(indsₑ; is_self_loop=is_self_loop(e)))
  end
  for v in vertices(g)
    vlabel = vertex_labels[v]
    set_prop!(g, v, label_key, vlabel)
  end
  return g
end

function visualize(tn::Vector{ITensor}; label_key=default_label_key(), vertex_labels=default_vertex_labels(tn), kwargs...)
  g = MetaGraph(tn)
  set_labels!(g; label_key, vertex_labels)
  return visualize(g; kwargs...)
end

visualize(ψ::MPS; kwargs...) = visualize(data(ψ); layout=Grid(), kwargs...)
