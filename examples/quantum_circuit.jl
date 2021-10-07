using ITensors
using ITensorsVisualization
using LayeredLayouts
using LightGraphs
using GLMakie

ITensorsVisualization.set_backend!("Makie")

function layered_layout(g)
 xs, ys, _ = solve_positions(Zarate(), g)
 return Point.(zip(xs, ys))
end

function circuit_network(gates, s::Vector{<:Index})
  s = copy(s)
  U = ITensor[]
  for g in gates
    push!(U, op(g, s))
    for n in g[2:end]
      s[n] = s[n]'
    end
  end
  return U, s
end

N = 10
layers = 10
ndelete = 0

s = siteinds("Qubit", N)
layer(N, start) = [("CX", i, i + 1) for i in start:2:(N - 1)]
layer(N) = append!(layer(N, 1), layer(N, 2))
layer_N = layer(N)
gates = []
for _ in 1:layers
  append!(gates, layer_N)
end

for _ in 1:ndelete
  deleteat!(gates, rand(eachindex(gates)))
end

U, s̃ = circuit_network(gates, s)
ψ = prod(MPS(s))
ψ̃ = prod(MPS(s̃))
tn = [ψ, U..., ψ̃]

@visualize tn show=(arrows=true, plevs=true) layout=layered_layout
