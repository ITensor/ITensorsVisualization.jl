#############################################################################
# vertex labels
#

function default_vertex(g::AbstractGraph)
  labels_prefix = default_vertex_labels_prefix(g)
  return (
    labels_prefix=labels_prefix,
    labels=default_vertex_labels(g, labels_prefix),
    size=default_vertex_size(g),
    textsize=default_vertex_textsize(g)
  )
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

default_vertex_labels_prefix(g) = "T"
function default_vertex_labels(r::AbstractRange, vertex_labels_prefix=default_vertex_labels_prefix())
  return [string(vertex_labels_prefix, subscript(n)) for n in r]
end
default_vertex_labels(g::AbstractGraph, vertex_labels_prefix) = default_vertex_labels(vertices(g), vertex_labels_prefix)
default_vertex_labels(tn::AbstractArray{ITensor}, vertex_labels_prefix) = default_vertex_labels(eachindex(tn), vertex_labels_prefix)

default_vertex_size(g) = 35
default_vertex_textsize(g) = 20

#############################################################################
# edge
#

default_edge(g; show) = (textsize=default_edge_textsize(), widths=default_widths(g), labels=default_edge_labels(g; show=show))

#############################################################################
# edge labels
#

default_show(g::AbstractGraph) = (dims=true, tags=false, ids=false, plevs=false, qns=false, arrows=_hasqns(g))

default_edge_textsize() = 30

function edge_label(g, e; show)
  indsₑ = get_prop(g, e, :inds)
  return label_string(indsₑ; is_self_loop=is_self_loop(e), show=show)
end

function default_edge_labels(g; show)
  return [edge_label(g, e; show=show) for e in edges(g)]
end

supports_newlines(::Backend) = true
supports_newlines(::Nothing) = true
supports_newlines(str::String) = supports_newlines(Backend(str))

_hasqns(tn::Vector{ITensor}) = any(hasqns, tn)
_hasqns(g::AbstractGraph) = hasqns(get_prop(g, first(edges(g)), :inds))

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
  if dir(i) == ITensors.In
    str *= "†"
  end
  return str
end

function label_string(i::Index; show)
  str = ""
  if any((show.tags, show.plevs, show.ids, show.qns))
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
  if any((show.tags, show.plevs, show.ids, show.qns))
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

#############################################################################
# edge width
#

function width(inds)
  return log2(dim(inds)) + 1
end

function default_widths(g::AbstractGraph)
  return [width(get_prop(g, e, :inds)) for e in edges(g)]
end

#############################################################################
# edge arrow
#

default_arrow(g) = (size=30,)

#############################################################################
# dimensions
#

_ndims(::Any) = 2
_ndims(::NetworkLayout.AbstractLayout{N}) where {N} = N
