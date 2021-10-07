using ITensors
using LayeredLayouts

function layered_layout(g)
 xs, ys, _ = solve_positions(Zarate(), g)
 return Point.(zip(xs, ys))
end

sites(g::Tuple{String,<:Tuple}) = g[2]
sites(g::Tuple{String,<:Tuple,<:NamedTuple}) = g[2]
sites(g::Tuple{String,Int}) = g[2]
sites(g::Tuple{String,Int,<:NamedTuple}) = g[2]

function circuit_network(gates, s::Vector{<:Index})
  s = copy(s)
  U = ITensor[]
  for g in gates
    push!(U, op(g, s))
    for n in sites(g)
      s[n] = s[n]'
    end
  end
  return U, s
end
