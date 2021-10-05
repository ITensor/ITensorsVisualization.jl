using ITensors
using ITensorsVisualization
using LightGraphs

g = grid((5,))
for v in vertices(g)
  add_edge!(g, v => v)
end
tn = itensornetwork(g; linkspaces=10, sitespaces=2)
@visualize tn
