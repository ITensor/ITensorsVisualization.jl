using GraphMakie
using GraphMakie.Makie:
  Makie,
  hidedecorations!,
  hidespines!,
  deregister_interaction!,
  register_interaction! 

fill_number(a::AbstractVector, n::Integer) = a
fill_number(x::Number, n::Integer) = fill(x, n)

function visualize(
  b::Backend"Makie",
  g::AbstractGraph;
  interactive=true,
  ndims=2,
  layout=Spring(dim=ndims),
  vertex=(;),
  visualize_macro_vertex_labels_prefix=nothing,
  visualize_macro_vertex_labels=nothing,
  show=default_show(b, g),
  edge=default_edge(b, g; show=merge(default_show(b, g), show)),
  arrow=default_arrow(b, g),
  siteind_direction=Point2(0, -1), # TODO: come up with a better name
)
  if ismissing(Makie.current_backend[])
    error("""
      You have not loaded a backend.  Please load one (`using GLMakie` or `using CairoMakie`)
      before trying to visualize a graph.
    """)
  end

  # If vertex labels were set by the macro interface, use those unless
  # labels were already set previously
  if !haskey(vertex, :labels) && !isnothing(visualize_macro_vertex_labels)
    vertex = merge(vertex, (labels=visualize_macro_vertex_labels,))
  end

  if !haskey(vertex, :labels) && !isnothing(visualize_macro_vertex_labels_prefix)
    vertex = merge(vertex, (labels=default_vertex_labels(b, g, visualize_macro_vertex_labels_prefix),))
  end

  # Merge with default values to fill in any missing values
  vertex = merge(default_vertex(b, g), vertex)
  show = merge(default_show(b, g), show)
  edge = merge(default_edge(b, g; show=show), edge)
  arrow = merge(default_arrow(b, g), arrow)

  f, ax, p = graphplot(
    g;
    layout=layout,

    # vertex
    node_size=fill_number(vertex.size, nv(g)),
    node_color=colorant"lightblue1", # TODO: store in vertex, make a default
    node_marker='●', # TODO: allow other options, like '◼'
    node_attr=(; strokecolor=:black, strokewidth=3),

    # vertex labels
    nlabels = vertex.labels,
    nlabels_textsize = vertex.textsize,
    nlabels_color=colorant"black",
    nlabels_align=(:center, :center),

    # edge
    edge_width=edge.widths,
    edge_color=colorant"black",

    # edge labels
    elabels=edge.labels,
    elabels_textsize=edge.textsize,
    elabels_color=colorant"red",

    # self-edge
    selfedge_width=1e-5, # Small enough so you can't see the loop, big enough for site label to show up
    selfedge_direction=siteind_direction,
    selfedge_size=3,

    # arrow
    arrow_show=show.arrows,
    arrow_size=arrow.size,
    arrow_shift=0.49,
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
