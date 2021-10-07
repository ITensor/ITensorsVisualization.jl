using ITensors
using ITensorsVisualization
using LayeredLayouts
using LightGraphs
using GLMakie

ITensorsVisualization.set_backend!("Makie")

function layout(g)
 xs, ys, _ = solve_positions(Zarate(), g)
 return Point.(zip(xs, ys))
end

tn = itensornetwork(Grid((4, 4)); linkspaces=3)
@visualize tn show=(arrows=true,) layout=layout
