using ITensors
using ITensorsVisualization
using LayeredLayouts
using LightGraphs
using GLMakie

function layout(g)
 xs, ys, _ = solve_positions(Zarate(), g)
 return Point.(zip(xs, ys))
end

tn = itensornetwork(Grid((4, 4)); linkspaces=3)
@visualize fig tn show=(arrows=true,) layout=layout backend="Makie"

fig
