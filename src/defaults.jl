#############################################################################
# vertex labels
#

## function default_vertex(b::Backend, g::AbstractGraph)
##   labels_prefix = default_vertex_labels_prefix(b, g)
##   return (
##     labels_prefix=labels_prefix,
##     labels=default_vertex_labels(b, g, labels_prefix),
##     size=default_vertex_size(b, g),
##     textsize=default_vertex_textsize(b, g)
##   )
## end

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

default_vertex_labels_prefix(b::Backend, g) = "T"
function default_vertex_labels(b::Backend, g::AbstractGraph, vertex_labels_prefix=default_vertex_labels_prefix(b))
  return [string(vertex_labels_prefix, subscript(v)) for v in vertices(g)]
end

#default_vertex_labels(tn::AbstractArray{ITensor}, vertex_labels_prefix) = default_vertex_labels(eachindex(tn), vertex_labels_prefix)

default_vertex_size(b::Backend, g) = 60
default_vertex_textsize(b::Backend, g) = 20

#############################################################################
# edge
#

#function default_edge(b::Backend, g; show)
#  return (textsize=default_edge_textsize(b), widths=default_widths(b, g), labels=default_edge_labels(b, g; show=show))
#end

#############################################################################
# edge labels
#

#default_show(b::Backend, g::AbstractGraph) = (dims=true, tags=false, ids=false, plevs=false, qns=false, arrows=_hasqns(g))

default_edge_textsize(b::Backend) = 30

function edge_label(g, e; kwargs...)
  indsₑ = get_prop(g, e, :inds)
  return label_string(indsₑ; is_self_loop=is_self_loop(e), kwargs...)
end

function default_edge_labels(b::Backend, g; kwargs...)
  return [edge_label(g, e; kwargs...) for e in edges(g)]
end

supports_newlines(::Backend) = true
supports_newlines(::Nothing) = true
supports_newlines(str::String) = supports_newlines(Backend(str))

_hasqns(tn::Vector{ITensor}) = any(hasqns, tn)
function _hasqns(g::AbstractGraph)
  if iszero(ne(g))
    if has_prop(g, first(vertices(g)), :inds)
      return hasqns(get_prop(g, first(vertices(g)), :inds))
    else
      return hasqns(())
    end
  end
  return hasqns(get_prop(g, first(edges(g)), :inds))
end

default_arrow_show(b::Backend, g) = _hasqns(g)

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

function label_string(i::Index; show_dims, show_tags, show_plevs, show_ids, show_qns)
  str = ""
  if any((show_tags, show_plevs, show_ids, show_qns))
    str *= "("
  end
  if show_dims
    str *= string(dim(i))
  end
  if show_ids
    if show_dims
      str *= "|"
    end
    str *= idstring(i)
  end
  if show_tags
    if any((show_dims, show_ids))
      str *= "|"
    end
    str *= tagsstring(i)
  end
  if any((show_tags, show_plevs, show_ids, show_qns))
    str *= ")"
  end
  if show_plevs
    str *= plevstring(i)
  end
  if show_qns
    str *= qnstring(i)
  end
  return str
end

function label_string(is; is_self_loop=false, newlines=true, show_dims, show_tags, show_plevs, show_ids, show_qns)
  str = ""
  for n in eachindex(is)
    str *= label_string(is[n]; show_dims, show_tags, show_plevs, show_ids, show_qns)
    if n ≠ lastindex(is)
      if any((show_dims, show_tags, show_ids, show_qns))
        str *= "⊗"
      end
      if newlines && any((show_tags, show_ids, show_qns))
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

function default_edge_widths(b::Backend, g::AbstractGraph)
  return [width(get_prop(g, e, :inds)) for e in edges(g)]
end

#############################################################################
# edge arrow
#

default_arrow_size(b::Backend, g) = 30

#############################################################################
# dimensions
#

_ndims(::Any) = 2
_ndims(::NetworkLayout.AbstractLayout{N}) where {N} = N
