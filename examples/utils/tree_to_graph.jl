using AbstractTrees
using LightGraphs

tree_to_graph(tr) = tree_to_graph(Tree(tr))

function tree_to_graph(tr::Tree)
  g = SimpleDiGraph()
  labels = Any[]
  walk_tree!(g, labels, tr)
  return (g, labels)
end

function walk_tree!(g, labels, tr::Tree)
  add_vertex!(g)
  top_vertex = vertices(g)[end]
  push!(labels, tr.x)
  for i in 1:length(tr.x)
    if isa(tr[i], Vector)
      child = walk_tree!(g, labels, Tree(tr[i]))
      add_edge!(g, child, top_vertex)
    else
      add_vertex!(g)
      n = vertices(g)[end]
      add_edge!(g, n, top_vertex)
      push!(labels, tr[i])
    end
  end
  return top_vertex
end
