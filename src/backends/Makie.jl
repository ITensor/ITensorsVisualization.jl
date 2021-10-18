using GraphMakie
using GraphMakie.Makie:
  Makie,
  Figure,
  hidedecorations!,
  hidespines!,
  deregister_interaction!,
  register_interaction! 

fill_number(a::AbstractVector, n::Integer) = a
fill_number(x::Number, n::Integer) = fill(x, n)

function visualize(b::Backend"Makie", g::AbstractGraph; kwargs...)
  f = Figure()
  visualize!(b, f[1, 1], g; kwargs...)
  return f
end

function visualize!(
  b::Backend"Makie",
  f,
  g::AbstractGraph;
  interactive=true,
  ndims=2,
  layout=Spring(dim=ndims),

  # vertex
  vertex_labels_prefix=default_vertex_labels_prefix(b, g),
  vertex_labels=default_vertex_labels(b, g, vertex_labels_prefix),
  vertex_size=default_vertex_size(b, g),
  vertex_textsize=default_vertex_textsize(b, g),

  # edge labels show
  show_dims=true, # TODO: replace with `default_show_dims(b, g)`
  show_tags=false,
  show_ids=false,
  show_plevs=false,
  show_qns=false,

  # edge
  edge_textsize=default_edge_textsize(b),
  edge_widths=default_edge_widths(b, g),
  edge_labels=default_edge_labels(b, g; show_dims, show_tags, show_ids, show_plevs, show_qns),

  # arrow
  arrow_show=default_arrow_show(b, g),
  arrow_size=default_arrow_size(b, g),

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
  #if !haskey(vertex, :labels) && !isnothing(visualize_macro_vertex_labels)
  #  vertex = merge(vertex, (labels=visualize_macro_vertex_labels,))
  #end

  #if !haskey(vertex, :labels) && !isnothing(visualize_macro_vertex_labels_prefix)
  #  vertex = merge(vertex, (labels=default_vertex_labels(b, g, visualize_macro_vertex_labels_prefix),))
  #end

  # Merge with default values to fill in any missing values
  #vertex = merge(default_vertex(b, g), vertex)
  #show = merge(default_show(b, g), show)
  #edge = merge(default_edge(b, g; show=show), edge)
  #arrow = merge(default_arrow(b, g), arrow)

  axis_plot = graphplot(
    f,
    g;
    layout=layout,

    # vertex
    node_size=fill_number(vertex_size, nv(g)),
    node_color=colorant"lightblue1", # TODO: store in vertex, make a default
    node_marker='●', # TODO: allow other options, like '◼'
    node_attr=(; strokecolor=:black, strokewidth=3),

    # vertex labels
    nlabels=vertex_labels,
    nlabels_textsize=vertex_textsize,
    nlabels_color=colorant"black",
    nlabels_align=(:center, :center),

    # edge
    edge_width=edge_widths,
    edge_color=colorant"black",

    # edge labels
    elabels=edge_labels,
    elabels_textsize=edge_textsize,
    elabels_color=colorant"red",

    # self-edge
    selfedge_width=1e-5, # Small enough so you can't see the loop, big enough for site label to show up
    selfedge_direction=siteind_direction,
    selfedge_size=3,

    # arrow
    arrow_show=arrow_show,
    arrow_size=arrow_size,
    arrow_shift=0.49,
  )
  if _ndims(layout) == 2
    hidedecorations!(axis_plot.axis)
    hidespines!(axis_plot.axis)
    if interactive
      deregister_interaction!(axis_plot.axis, :rectanglezoom)
      register_interaction!(axis_plot.axis, :nhover, NodeHoverHighlight(axis_plot.plot))
      register_interaction!(axis_plot.axis, :ehover, EdgeHoverHighlight(axis_plot.plot))
      register_interaction!(axis_plot.axis, :ndrag, NodeDrag(axis_plot.plot))
      register_interaction!(axis_plot.axis, :edrag, EdgeDrag(axis_plot.plot))
    end
  end
  return f
end
