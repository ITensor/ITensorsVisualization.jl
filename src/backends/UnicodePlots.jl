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

function draw_edge!(backend::Backend"UnicodePlots", plot, v1, v2; color)
  UnicodePlots.lineplot!(plot, [v1[1], v2[1]], [v1[2], v2[2]]; color)
  return plot
end

function annotate!(::Backend"UnicodePlots", plot, x, y, str)
  UnicodePlots.annotate!(plot, x, y, str)
  return plot
end

supports_newlines(::Backend"UnicodePlots") = false

function visualize(
  backend::Backend,
  g::AbstractGraph;
  #label_key=:label,
  #color_key=:color,
  #vertex_size=0.2,
  #vertex_color=edge_color,
  #vertex_labels=default_vertex_labels(g),
  interactive=false, # TODO: change to `default_interactive(backend)`
  ndims=2, # TODO: change to `default_ndims(backend)`
  layout=Spring(dim=ndims), # TODO: change to `default_layout(backend)`
  vertex=nothing,
  visualize_macro_vertex_labels=nothing,
  show=default_show(g),
  edge=default_edge(g; show=merge(default_show(g), show)),
  arrow=default_arrow(g),
  siteind_direction=Point2(0, -1), # TODO: come up with a better name
  width=50,
  height=20,
)
  # If vertex labels were set by the macro interface, use those unless
  # labels were already set previously
  if isnothing(vertex)
    vertex = (labels=visualize_macro_vertex_labels,)
  elseif !haskey(vertex, :labels)
    vertex = merge(vertex, (labels=visualize_macro_vertex_labels,))
  end

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
  plt = plot(backend; xlim=xlim, ylim=ylim, width=width, height=height)

  # Add edges and nodes
  for (e_pos, e) in zip(edge_pos, edges(g))
    if is_self_loop(e)
      draw_edge!(backend, plt, e_pos[1], e_pos[1] + site_vertex_shift; color=edge_color)
    else
      draw_edge!(backend, plt, e_pos[1], e_pos[2]; color=edge_color)
    end
  end

  ## for v in vertices(g)
  ##   x, y = node_pos[v]
  ##   #node_label = get_prop_default(g, v, label_key, vertex.labels[v])
  ##   node_label = vertex.labels[v]
  ## end

  # Add edge labels and node labels
  for (n, e) in enumerate(edges(g))
    e_pos = edge_pos[n]
    #edge_label = get_prop_default(g, e, label_key, string(e))
    edge_label = edge.labels[n]
    if is_self_loop(e)
      @assert e_pos[1] == e_pos[2]
      str_pos = e_pos[1] + site_vertex_shift
      annotate!(backend, plt, str_pos..., edge_label)
    else
      annotate!(backend, plt, mean(e_pos)..., edge_label)
    end
  end
  for v in vertices(g)
    x, y = node_pos[v]
    #node_label = get_prop_default(g, v, label_key, string(v))
    node_label = vertex.labels[v]
    annotate!(backend, plt, x, y, node_label)
  end
  return plt
end
