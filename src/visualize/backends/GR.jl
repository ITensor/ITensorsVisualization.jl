function clear_axis!(plot)
  GRUtils.grid!(plot, false)
  GRUtils.xticklabels!(plot, String[""])
  GRUtils.yticklabels!(plot, String[""])
  GRUtils.xticks!(plot, 0)
  GRUtils.yticks!(plot, 0)
end

function plot(::Val{:GR};
  xlim,
  ylim,
  width,
  height,
)
  plot = GRUtils.plot([])
  clear_axis!(plot)
  return plot
end

translate_color(::Val{:GR}, ::Val{:blue}) = "b"

function draw_edge!(backend::Val{:GR}, plot, v1, v2; color)
  gr_color = translate_color(backend, Val(color))
  x, y = point_to_line(v1, v2)
  GRUtils.oplot!(plot, x, y, gr_color) #; kwargs...)
  clear_axis!(plot)
  return plot
end

function annotate!(::Val{:GR}, plot, x, y, str)
  GRUtils.annotations!(plot, x, y, str)
  clear_axis!(plot)
  return plot
end

## function lineplot!(backend::Val{:GR}, plot, f::Function, x1, x2; kwargs...)
##   r = range(x1, x2; length=100)
##   lineplot!(backend, plot, r, f.(r)) #; kwargs...) 
##   return plot
## end
