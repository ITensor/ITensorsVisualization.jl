
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
        if dir(uncontracted_indᵢ) == ITensors.Out
          edge = reverse(edge)
        else
          uncontracted_indᵢ = dag(uncontracted_indᵢ)
        end
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

function get_source_destiny_weight(source::AbstractVector, destiny::AbstractVector)
  if length(source) != length(destiny)
    throw(ArgumentError("Source and destiny must have the same length."))
  end
  source, destiny, Float64[ 1.0 for i in source ]
end

function get_source_destiny_weight(adjlist::AbstractVector{V}) where V<:AbstractVector{T} where T<:Any
  source = Int[]
  destiny = Int[]
  for (i,l) in enumerate(adjlist)
    for j in l
      push!(source, i)
      push!(destiny, j)
    end
  end
  return get_source_destiny_weight(source, destiny)
end

function get_adjacency_matrix(source::AbstractVector{Int}, destiny::AbstractVector{Int}, weights::AbstractVector)
  n = max(maximum(source), maximum(destiny))
  Matrix(sparse(source, destiny, weights, n, n))
end

# GraphRecipes.get_adjacency_matrix(adjlist)
function get_adjacency_matrix(adjlist::Vector{Vector{Int}})
  s, d, w = get_source_destiny_weight(adjlist)
  return get_adjacency_matrix(s, d, w)
end

function get_adjacency_matrix(edge_index_list::Dict{Tuple{Int, Int}, Vector{Index}})
  return get_adjacency_matrix(get_adjacency_list(edge_index_list))
end

