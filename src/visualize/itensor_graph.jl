hasuniqueinds(args...; kwargs...) = !isempty(uniqueinds(args...; kwargs...))

function LightGraphs.SimpleGraph(tn::Vector{ITensor})
  nv = length(tn)
  g = SimpleGraph(nv)
  for v1 in 1:nv, v2 in (v1 + 1):nv
    if hascommoninds(tn[v1], tn[v2])
      add_edge!(g, v1 => v2)
    end
  end
  for v in vertices(g)
    if hasuniqueinds(tn[v], tn[neighbors(g, v)]...)
      # Add a self-loop
      add_edge!(g, v => v)
    end
  end
  return g
end

function MetaGraphs.MetaGraph(tn::Vector{ITensor})
  sg = SimpleGraph(tn)
  mg = MetaGraph(sg)
  for e in edges(mg)
    indsₑ = if is_self_loop(e)
      v = src(e)
      # For self edges, the vertex itself is included as
      # a neighbor so we must exclude it.
      uniqueinds(tn[v], tn[setdiff(neighbors(mg, v), v)]...)
    else
      commoninds(tn[src(e)], tn[dst(e)])
    end
    set_prop!(mg, e, :inds, indsₑ)
  end
  return mg
end
