using ITensors
using ITensorsVisualization
using LightGraphs

g = grid((5,))
tn = itensornetwork(g; linkspaces=10, sitespaces=2)
@visualize tn