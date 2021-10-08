using GraphMakie
using GraphMakie.Makie:
  Makie,
  hidedecorations!,
  hidespines!,
  deregister_interaction!,
  register_interaction! 

function nlabels_default(g::AbstractGraph; label_key=default_label_key())
  return [get_prop_default(g, v, label_key, string(v)) for v in vertices(g)]
end

function elabels_default(g::AbstractGraph; label_key=default_label_key())
  return [get_prop_default(g, e, label_key, string(e)) for e in edges(g)]
end

function edge_width_default(g::AbstractGraph; width_key=default_width_key(), default=5)
  return [get_prop_default(g, e, width_key, default) for e in edges(g)]
end

_ndims(::Any) = 2
_ndims(::NetworkLayout.AbstractLayout{N}) where {N} = N

default_vertex() = (size=35, textsize=20)
default_edge() = (textsize=30,)
default_arrow() = (size=30,)

function visualize(
  backend::Backend"Makie",
  g::AbstractGraph;
  interactive=true,
  siteind_direction=Point2(0, -1),
  ndims=2,
  layout=Spring(dim=ndims),
  vertex=default_vertex(),
  edge=default_edge(),
  arrow=default_arrow(),
  show,
)
  vertex = merge(default_vertex(), vertex)
  edge = merge(default_edge(), edge)
  arrow = merge(default_arrow(), arrow)
  if ismissing(Makie.current_backend[])
    error("""
      You have not loaded a backend.  Please load one (`using GLMakie` or `using CairoMakie`)
      before trying to visualize a graph.
    """)
  end
  node_size = vertex.size isa Number ? [vertex.size for _ in 1:nv(g)] : vertex.size
  f, ax, p = graphplot(
    g;
    layout=layout,
    node_size=node_size,
    node_color=colorant"lightblue1",
    nlabels=nlabels_default(g),
    nlabels_color=colorant"black",
    nlabels_textsize=vertex.textsize,
    nlabels_align=(:center, :center),
    edge_width=edge_width_default(g),
    edge_color=colorant"black",
    elabels=elabels_default(g),
    elabels_color=colorant"red",
    elabels_textsize=edge.textsize,
    selfedge_width=1e-5, # Small enough so you can't see the loop, big enough for site label to show up
    selfedge_direction=siteind_direction,
    selfedge_size=3,
    arrow_show=show.arrows,
    arrow_shift=0.49,
    arrow_size=arrow.size,
    node_marker='●', #'◼',
    node_attr=(; strokecolor=:black, strokewidth=3),
  )
  if _ndims(layout) == 2
    hidedecorations!(ax)
    hidespines!(ax)
    if interactive
      deregister_interaction!(ax, :rectanglezoom)
      register_interaction!(ax, :nhover, NodeHoverHighlight(p))
      register_interaction!(ax, :ehover, EdgeHoverHighlight(p))
      register_interaction!(ax, :ndrag, NodeDrag(p))
      register_interaction!(ax, :edrag, EdgeDrag(p))
    end
  end
  return f
end
