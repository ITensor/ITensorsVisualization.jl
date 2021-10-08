"""
    Grid

Gride layout.
"""
struct Grid end

(::Grid)(g) = Point.(5 .* (vertices(g) .- 1), 0)

is_self_loop(e::AbstractEdge) = src(e) == dst(e)
any_self_loops(g::AbstractGraph) = any(is_self_loop, edges(g))

get_prop_default(g::SimpleGraph, prop_default...) = last(prop_default)
get_prop_default(g::SimpleDiGraph, prop_default...) = last(prop_default)

function get_prop_default(g::AbstractGraph, prop_default...)
  prop = Base.front(prop_default)
  default = last(prop_default)
  return has_prop(g, prop...) ? get_prop(g, prop...) : default
end

function visualize(g::AbstractGraph; backend=get_backend(), kwargs...)
  backend = isnothing(backend) ? default_backend() : Backend(backend)
  return visualize(Backend(backend), g; kwargs...)
end

default_vertex_labels(g) = [string(v) for v in vertices(g)]

function visualize(
  backend::Backend,
  g::AbstractGraph;
  layout=Spring(),
  label_key=:label,
  color_key=:color,
  edge_color=:blue,
  vertex_size=0.2,
  vertex_color=edge_color,
  vertex_labels=default_vertex_labels(g),
  width=50,
  height=20,
  kwargs...
)
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
  for v in vertices(g)
    x, y = node_pos[v]
    node_label = get_prop_default(g, v, label_key, vertex_labels[v])
  end

  # Add edge labels and node labels
  for (e_pos, e) in zip(edge_pos, edges(g))
    edge_label = get_prop_default(g, e, label_key, string(e))
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
    node_label = get_prop_default(g, v, label_key, string(v))
    annotate!(backend, plt, x, y, node_label)
  end
  return plt
end
