using UnicodePlots: UnicodePlots

function plot(::Backend"UnicodePlots"; xlim, ylim, width, height)
  plot = UnicodePlots.lineplot(
    [0.0],
    [0.0];
    border=:none,
    labels=false,
    grid=false,
    xlim=xlim,
    ylim=ylim,
    width=width,
    height=height,
  )
  return plot
end

function draw_edge!(b::Backend"UnicodePlots", plot, v1, v2; color)
  UnicodePlots.lineplot!(plot, [v1[1], v2[1]], [v1[2], v2[2]]; color)
  return plot
end

function annotate!(::Backend"UnicodePlots", plot, x, y, str)
  UnicodePlots.annotate!(plot, x, y, str)
  return plot
end

supports_newlines(::Backend"UnicodePlots") = false

function visualize(
  b::Backend"UnicodePlots",
  g::AbstractGraph;
  interactive=false, # TODO: change to `default_interactive(b)`
  ndims=2, # TODO: change to `default_ndims(b)`
  layout=Spring(dim=ndims), # TODO: change to `default_layout(b, ndims)`

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
  width=50,
  height=20,
)
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

  edge_color=:blue # TODO: add into `edge`

  node_pos = layout(g)
  edge_pos = [node_pos[src(edge)] => node_pos[dst(edge)] for edge in edges(g)]
  xmin = minimum(first.(node_pos))
  xmax = maximum(first.(node_pos))
  ymin = minimum(last.(node_pos))
  ymax = maximum(last.(node_pos))

  #vertex_size = vertex_size * (xmax - xmin)

  xscale = 0.5 * (xmax - xmin)
  yscale = max(0.5 * (ymax - ymin), 0.01 * xscale)
  xlim = [xmin - xscale, xmax + xscale]
  ylim = [ymin - yscale, ymax + yscale]

  # Good for periodic MPS
  site_vertex_shift = -Point(0, 0.2 * abs(ylim[2] - ylim[1]))

  # Good for open boundary MPS
  #site_vertex_shift = -Point(0, 0.001 * (xmax - xmin))

  # Initialize the plot
  plt = plot(b; xlim=xlim, ylim=ylim, width=width, height=height)

  # Add edges and nodes
  for (e_pos, e) in zip(edge_pos, edges(g))
    if is_self_loop(e)
      draw_edge!(b, plt, e_pos[1], e_pos[1] + site_vertex_shift; color=edge_color)
    else
      draw_edge!(b, plt, e_pos[1], e_pos[2]; color=edge_color)
    end
  end

  # Add edge labels and node labels
  for (n, e) in enumerate(edges(g))
    e_pos = edge_pos[n]
    edge_label = edge_labels[n]
    if is_self_loop(e)
      @assert e_pos[1] == e_pos[2]
      str_pos = e_pos[1] + site_vertex_shift
      annotate!(b, plt, str_pos..., edge_label)
    else
      annotate!(b, plt, mean(e_pos)..., edge_label)
    end
  end
  if length(vertex_labels) ≠ nv(g)
    throw(DimensionMismatch("Number of vertex labels must equal the number of vertices. Vertex labels $(vertex.labels) of length $(length(vertex.labels)) does not equal the number of vertices $(nv(g))."))
  end
  for v in vertices(g)
    x, y = node_pos[v]
    node_label = vertex_labels[v]
    annotate!(b, plt, x, y, node_label)
  end
  return plt
end
