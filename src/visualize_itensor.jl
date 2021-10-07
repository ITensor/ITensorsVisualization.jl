plevstring(i::Index) = ITensors.primestring(plev(i))
idstring(i::Index) = string(id(i) % 1000)
tagsstring(i::Index) = string(tags(i))
qnstring(i::Index) = ""
function qnstring(i::QNIndex)
  str = "["
  for (n, qnblock) in pairs(space(i))
    str *= "$qnblock"
    if n ≠ lastindex(space(i))
      str *= ", "
    end
  end
  str *= "]"
  return str
end

function label_string(i::Index; show)
  str = ""
  if any((show.tags, show.plevs, show.ids))
    str *= "("
  end
  if show.dims
    str *= string(dim(i))
  end
  if show.ids
    if show.dims
      str *= "|"
    end
    str *= idstring(i)
  end
  if show.tags
    if any((show.dims, show.ids))
      str *= "|"
    end
    str *= tagsstring(i)
  end
  if any((show.tags, show.plevs, show.ids))
    str *= ")"
  end
  if show.plevs
    str *= plevstring(i)
  end
  if show.qns
    str *= qnstring(i)
  end
  return str
end

function label_string(is; is_self_loop=false, newlines=true, show)
  str = ""
  for n in eachindex(is)
    str *= label_string(is[n]; show)
    if n ≠ lastindex(is)
      if any((show.dims, show.tags, show.ids, show.qns))
        str *= "⊗"
      end
      if newlines && any((show.tags, show.ids, show.qns))
        str *= "\n"
      end
    end
  end
  return str
end

function subscript_char(n::Integer)
  @assert 0 ≤ n ≤ 9
  return Char(0x2080 + n)
end

function subscript(n::Integer)
  ss = prod(Iterators.reverse((subscript_char(d) for d in digits(abs(n)))))
  if n < 0
    ss = "₋" * ss
  end
  return ss
end

default_vertex_labels_prefix() = "T"
function default_vertex_labels(r::AbstractRange, vertex_labels_prefix=default_vertex_labels_prefix())
  return [string(vertex_labels_prefix, subscript(n)) for n in r]
end
default_vertex_labels(g::AbstractGraph, vertex_labels_prefix) = default_vertex_labels(vertices(g), vertex_labels_prefix)
default_vertex_labels(tn::AbstractArray{ITensor}, vertex_labels_prefix) = default_vertex_labels(eachindex(tn), vertex_labels_prefix)

default_label_key() = :label
default_width_key() = :width

function set_labels!(g::AbstractGraph; label_key, vertex_labels, kwargs...)
  for e in edges(g)
    # This includes self-loops
    indsₑ = get_prop(g, e, :inds)
    set_prop!(g, e, label_key, label_string(indsₑ; is_self_loop=is_self_loop(e), kwargs...))
  end
  for v in vertices(g)
    vlabel = vertex_labels[v]
    set_prop!(g, v, label_key, vlabel)
  end
  return g
end

function width(inds)
  return log2(dim(inds)) + 1
end

function set_widths!(g::AbstractGraph; width_key)
  for e in edges(g)
    # This includes self-loops
    indsₑ = get_prop(g, e, :inds)
    set_prop!(g, e, width_key, width(indsₑ))
  end
  return g
end

supports_newlines(::Backend) = true
supports_newlines(::Nothing) = true
supports_newlines(str::String) = supports_newlines(Backend(str))

_hasqns(tn::Vector{ITensor}) = any(hasqns, tn)

default_show(tn::Vector{ITensor}) = (dims=true, tags=false, ids=false, plevs=false, qns=false, arrows=_hasqns(tn))

function visualize(
  tn::Vector{ITensor};
  label_key=default_label_key(),
  width_key=default_width_key(),
  vertex_labels_prefix=default_vertex_labels_prefix(),
  vertex_labels=default_vertex_labels(tn, vertex_labels_prefix),
  show=default_show(tn),
  newlines=true,
  backend=get_backend(),
  kwargs...,
)
  show = merge(default_show(tn), show)
  g = MetaGraph(tn)
  if !supports_newlines(backend)
    newlines = false
  end
  set_labels!(g; label_key, vertex_labels, show, newlines)
  set_widths!(g; width_key)
  return visualize(g; backend, show, kwargs...)
end

visualize(ψ::MPS; kwargs...) = visualize(data(ψ); kwargs...)
visualize(tn::Tuple{Vararg{ITensor}}; kwargs...) = visualize(collect(tn); kwargs...)
visualize(tn::ITensor...; kwargs...) = visualize(collect(tn); kwargs...)
