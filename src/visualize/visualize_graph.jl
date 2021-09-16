"""
    Grid

Gride layout.
"""
struct Grid end

(::Grid)(g) = Point.(2 .* vertices(g), 0)

is_self_loop(e::AbstractEdge) = src(e) == dst(e)

get_prop_default(g::SimpleGraph, prop_default...) = last(prop_default)

function get_prop_default(g::AbstractGraph, prop_default...)
  prop = Base.front(prop_default)
  default = last(prop_default)
  return has_prop(g, prop...) ? get_prop(g, prop...) : default
end

function visualize(g::AbstractGraph; backend="UnicodePlots", kwargs...)
  return visualize(Val(Symbol(backend)), g; kwargs...)
end

function visualize(
  backend::Val,
  g::AbstractGraph;
  layout=Spring(),
  label_key=:label,
  color_key=:color,
  edge_color=:blue,
  vertex_size=0.2,
  vertex_color=edge_color,
)
  node_pos = layout(g)
  edge_pos = [node_pos[src(edge)] => node_pos[dst(edge)] for edge in edges(g)]
  xmin = minimum(first.(node_pos))
  xmax = maximum(first.(node_pos))
  ymin = minimum(last.(node_pos))
  ymax = maximum(last.(node_pos))

  #vertex_size = vertex_size * (xmax - xmin)

  xscale = 0.3 * (xmax - xmin)
  yscale = 0.3 * (ymax - ymin)
  xlim = [xmin - xscale, xmax + xscale]
  ylim = [ymin - yscale, ymax + yscale]
  plot = lineplot(
    backend,
    [0.],
    [0.];
    color=edge_color,
    border=:none,
    labels=false,
    grid=false,
    xlim=xlim,
    ylim=ylim,
    width=30,
    height=10,
  )
  for (e_pos, e) in zip(edge_pos, edges(g))
    xs = [e_pos[1][1], e_pos[2][1]]
    ys = [e_pos[1][2], e_pos[2][2]]
    edge_label = get_prop_default(g, e, label_key, string(e))
    if is_self_loop(e)
      x, y = xs[1], ys[1]
      @assert x, y == xs[2], ys[2]
      lineplot!(backend, plot, [x, x], [y, y - 1]; color=edge_color)
    else
      lineplot!(backend, plot, xs, ys; color=edge_color)
    end
    annotate!(backend, plot, mean(xs), mean(ys), edge_label)
  end
  for v in vertices(g)
    x, y = node_pos[v]
    circleplot!(backend, plot; x=x, y=y, r=vertex_size, color=vertex_color)
  end
  for v in vertices(g)
    x, y = node_pos[v]
    node_label = get_prop_default(g, v, label_key, string(v))
    annotate!(backend, plot, x, y, node_label; valign=:bottom)
  end
  return plot
end
