module ITensorsVisualization

using GraphRecipes
using ITensors
using Plots

function contraction_graph(As::ITensor...)
  N = length(As)

  # Make edges for the contracted indices
  edge_index_list = Dict{Tuple{Int, Int}, Vector{Index}}()
  for nodeᵢ in 1:N
    Aᵢ = As[nodeᵢ]
    for nodeⱼ in nodeᵢ:N
      if nodeᵢ ≠ nodeⱼ
        Aⱼ = As[nodeⱼ]
        for indAⱼ in inds(Aⱼ)
          pos = findfirst(==(indAⱼ), inds(Aᵢ))
          if !isnothing(pos)
            indAᵢ = ind(Aᵢ, pos)
            @assert dir(indAᵢ) == -dir(indAⱼ)
            if indAⱼ in inds(Aᵢ)
              edge = (nodeᵢ, nodeⱼ)
              if dir(indAⱼ) == ITensors.Out
                edge = reverse(edge)
              else
                indAⱼ = dag(indAⱼ)
              end
              current_indsᵢⱼ = get(edge_index_list, edge, Index[])
              indsᵢⱼ = push!(current_indsᵢⱼ, indAⱼ)
              edge_index_list[edge] = indsᵢⱼ
            end
          end
        end
      end
    end
  end

  # Make nodes out of the uncontracted indices
  uncontracted_inds = noncommoninds(As...)
  for nodeᵢ in N+1:N+length(uncontracted_inds)
    uncontracted_indᵢ = uncontracted_inds[nodeᵢ-N]
    for nodeⱼ in 1:N
      Aⱼ = As[nodeⱼ]
      pos = findfirst(==(uncontracted_indᵢ), inds(Aⱼ))
      if !isnothing(pos)
        edge = (nodeᵢ, nodeⱼ)
        edge_index_list[edge] = [uncontracted_indᵢ]
      end
    end
  end

  return edge_index_list
end

function get_adjacency_list(edge_index_list::Dict{Tuple{Int, Int}, Vector{Index}})
  # Determine the number of nodes from the edge list
  N = 1
  for edge in keys(edge_index_list)
    N = max(N, edge...)
  end

  # Make an adjacency list from the edge list (`adjlist[i]`: lists the nodes
  # that node `i` connects to)
  adjlist = Vector{Int}[Int[] for n in 1:N]
  for edge in keys(edge_index_list)
    for _ in 1:length(edge_index_list[edge])
      push!(adjlist[first(edge)], last(edge))
    end
  end
  return adjlist
end

function get_adjacency_matrix(adjlist::Vector{Vector{Int}})
  return GraphRecipes.get_adjacency_matrix(adjlist)
end

function get_adjacency_matrix(edge_index_list::Dict{Tuple{Int, Int}, Vector{Index}})
  return get_adjacency_matrix(get_adjacency_list(edge_index_list))
end

function visualize_contraction(As::ITensor...;
                               names = ["A$n" for n in 1:length(As)],
                               edgewidth = 5, showqns = false,
                               linklabels = "tags",
                               fontsize = 5, method = "stress",
                               edgelabel_offset = 0.0,
                               layout_kw = Dict{Symbol,Any}(), 
                               curves = false)
  edge_index_list = contraction_graph(As...)

  #
  # Compute the adjacency matrix/list
  #

  adjlist = get_adjacency_list(edge_index_list)
  #adjmatrix = get_adjacency_matrix(edge_index_list)

  #
  # Determine the edge widths from the Index dimensions
  #

  edgewidths = Dict{Tuple{Int, Int}, Float64}()
  for edge in keys(edge_index_list)
    edgewidths[edge] = prod(dim, edge_index_list[edge]) / length(edge_index_list[edge])
  end
  maxdim = maximum(last, edgewidths)
  for edge in keys(edge_index_list)
    edgewidths[edge] *= edgewidth / maxdim
  end

  #
  # Node labels are labels of the tensors
  # By default, make names of site nodes empty
  #

  append!(names, fill("", size(adjlist, 1) - length(names)))

  #
  # Determine the edge labels from the Index tags, etc.
  #

  edgelabels = Dict{Tuple{Int, Int, Int}, String}()
  for edge in keys(edge_index_list)
    inds = edge_index_list[edge]
    for nind in 1:length(inds)
      ind = inds[nind]
      if !showqns
        ind = removeqns(ind)
      end
      if linklabels == "tags"
        label = string(tags(ind))
      else
        io = IOBuffer()
        show(io, ind)
        label = String(take!(io))
      end
      edgelabels[(edge..., nind)] = label
    end
  end

  #
  # Plot the results
  #

  p = plot()
  graphplot!(p, adjlist; arrow = true, nodeshape = :circle,
             curves = curves,
             names = names, edgewidth = edgewidths, edgelabel = edgelabels,
             edgelabel_offset = edgelabel_offset, fontsize = fontsize,
             edgelabel_box = true, method = Symbol(method),
             layout_kw = layout_kw)
  return p
end

end
