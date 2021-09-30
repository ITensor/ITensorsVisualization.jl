using ITensors

include("graphplot.jl")
include("graphplot_itensor.jl")

vertex_name(v) = string(v)
edge_name(e) = string(src(e), "↔", dst(e))
label_key = :label
color_key = :color
layout = Spring(; iterations=1000)

nx, ny = 5, 5
#g = MetaGraph(grid((nx, ny)))
g = MetaDiGraph(grid((nx, ny)))

vertex_size = 0.2
vertex_color = :blue
edge_color = :red

for v in vertices(g)
  set_prop!(g, v, label_key, vertex_name(v))
  set_prop!(g, v, color_key, vertex_color)
end
for e in edges(g)
  set_prop!(g, e, label_key, edge_name(e))
  set_prop!(g, e, color_key, edge_color)
end

graphplot(g; label_key, vertex_size)

N = 5
s = siteinds("S=1/2", N)
ψ = randomMPS(s; linkdims=10)
graphplot(ψ)
