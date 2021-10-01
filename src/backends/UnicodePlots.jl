function plot(::Val{:UnicodePlots}; xlim, ylim, width, height)
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

function draw_edge!(backend::Val{:UnicodePlots}, plot, v1, v2; color)
  UnicodePlots.lineplot!(plot, [v1[1], v2[1]], [v1[2], v2[2]]; color)
  return plot
end

function annotate!(::Val{:UnicodePlots}, plot, x, y, str)
  UnicodePlots.annotate!(plot, x, y, str)
  return plot
end
