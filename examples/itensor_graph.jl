using ITensors
using ITensorsVisualize
using LightGraphs

g = Graph(5)
add_edge!(g, 1 => 2)
tn = itensornetwork(g)
@visualize tn

