function commoninds(g)
end

function LightGraphs.SimpleGraph(tn::Vector{ITensor})
  N = length(tn)
  g = SimpleGraph(N)
  for n1 in 1:N, n2 in (n1 + 1):N
    t1, t2 = tn[n1], tn[n2]
    if hascommoninds(t1, t2)
      add_edge!(g, n1 => n2)
    end
  end
  for v in vertices(g)
    if hasuniqueinds(tn[v], tn[neighbors(mg, v)]...)
      # Add a self-loop
      add_edge!(g, v1 => v2)
    end
  end
  return g
end

function MetaGraphs.MetaGraph(tn::Vector{ITensor})
  sg = SimpleGraph(tn)
  mg = MetaGraph(sg)
  for e in edges(mg)
    set_prop!(mg, e, :commoninds, commoninds(tn[src(e)], tn[dst(e)]))
  end
  for v in vertices(mg)
    set_prop!(mg, v, :uniqueinds, uniqueinds(tn[v], tn[neighbors(mg, v)]...))
  end
  return mg
end
