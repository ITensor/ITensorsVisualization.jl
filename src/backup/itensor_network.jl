using ITensors
using MetaGraphs
using LightGraphs

include("graphplot.jl")

function LightGraphs.SimpleGraph(tn::Vector{ITensor})
  N = length(tn)
  g = SimpleGraph(N)
  for n1 in 1:N, n2 in (n1 + 1):N
    t1, t2 = tn[n1], tn[n2]
    if hascommoninds(t1, t2)
      add_edge!(g, n1 => n2)
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

function label_string(i::Index)
  return string("(", dim(i), "|", tags(i), ")")
end

function label_string(is)
  s = ""
  for n in eachindex(is)
    s *= label_string(is[n])
    if n ≠ lastindex(is)
      s *= "⊗"
    end
  end
  return s
end

function graphplot(
  tn::Vector{ITensor}; label_key=:label, vertex_label=["T$n" for n in 1:length(tn)]
)
  g = MetaGraph(tn)
  for e in edges(g)
    commoninds_e = get_prop(g, e, :commoninds)
    set_prop!(g, e, label_key, label_string(commoninds_e))
  end
  for v in vertices(g)
    uniqueinds_v = get_prop(g, v, :uniqueinds)
    vlabel = vertex_label[v] * label_string(uniqueinds_v)
    set_prop!(g, v, label_key, vlabel)
  end
  return graphplot(g)
end

graphplot(ψ::MPS) = graphplot(ψ.data)

N = 5
s = siteinds("S=1/2", N)
ψ = randomMPS(s; linkdims=10)
graphplot(ψ)
