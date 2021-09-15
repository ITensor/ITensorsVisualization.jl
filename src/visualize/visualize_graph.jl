using NetworkLayout
using LightGraphs
using MetaGraphs
using UnicodePlots
using Statistics

function circleplot!(plot; x=0, y=0, r=1, kwargs...)
  iszero(r) && return plot
  ỹ(x̃) = √(abs(r^2 - (x̃ - x)^2))
  ỹ⁺(x̃) = ỹ(x̃) + y
  ỹ⁻(x̃) = -ỹ(x̃) + y
  lineplot!(plot, ỹ⁻, x - r, x + r; kwargs...)
  lineplot!(plot, ỹ⁺, x - r, x + r; kwargs...)
  return plot
end

function get_prop_default(g::AbstractGraph, prop_default...)
  prop = Base.front(prop_default)
  default = last(prop_default)
  return has_prop(g, prop...) ? get_prop(g, prop...) : default
end

function visualize(
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
    [0.],
    [0.];
    color=edge_color,
    border=:none,
    labels=false,
    grid=false,
    xlim=xlim,
    ylim=ylim,
    width=35,
    height=35,
  )
  for (e_pos, e) in zip(edge_pos, edges(g))
    xs = [e_pos[1][1], e_pos[2][1]]
    ys = [e_pos[1][2], e_pos[2][2]]
    lineplot!(plot, xs, ys; color=edge_color)
    annotate!(plot, mean(xs), mean(ys), get_prop_default(g, e, label_key, string(e)))
  end
  for v in vertices(g)
    x, y = node_pos[v]
    circleplot!(plot; x=x, y=y, r=vertex_size, color=vertex_color)
  end
  for v in vertices(g)
    x, y = node_pos[v]
    annotate!(plot, x, y, get_prop_default(g, v, label_key, string(v)))
  end
  return plot
end
