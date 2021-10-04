using Plots: Plots

function plot(::Backend"Plots"; xlim, ylim, width, height)
  plot = Plots.plot(;
    xticks=false, yticks=false, axis=false, grid=false, legend=false, xlim=xlim, ylim=ylim
  )
  return plot
end

function draw_edge!(backend::Backend"Plots", plot, v1, v2; color)
  Plots.plot!(plot, [v1[1], v2[1]], [v1[2], v2[2]]; color)
  return plot
end

function annotate!(::Backend"Plots", plot, x, y, str)
  Plots.annotate!(plot, x, y, str)
  return plot
end
