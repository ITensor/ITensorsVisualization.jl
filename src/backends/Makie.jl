using GraphMakie
using GraphMakie.Makie:
  Makie,
  Figure,
  contents,
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
  f::Figure,
  g::AbstractGraph;
  kwargs...
)
  visualize!(b, f[1, 1], g; kwargs...)
  return f
end

function visualize!(
  b::Backend"Makie",
  f::Makie.GridPosition,
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
  show_dims=default_show_dims(b, g),
  show_tags=default_show_tags(b, g),
  show_ids=default_show_ids(b, g),
  show_plevs=default_show_plevs(b, g),
  show_qns=default_show_qns(b, g),

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

  if length(vertex_labels) ≠ nv(g)
    throw(DimensionMismatch("$(length(vertex_labels)) vertex labels $(vertex_labels) were specified but there are $(nv(g)) tensors in the diagram, please specify the correct number of labels."))
  end

  graphplot_kwargs = (;
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

  overwrite_axis = false
  if isempty(contents(f))
    axis_plot = graphplot(f, g; graphplot_kwargs...)
  else
    @warn "Visualizing a graph in the same axis as an existing graph. This feature is experimental and some features like interactivity might now work"
    overwrite_axis = true
    graphplot!(f, g; graphplot_kwargs...)
  end

  if !overwrite_axis && (_ndims(layout) == 2)
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
