
function visualize_contraction(As::ITensor...;
                               names = ["A$n" for n in 1:length(As)],
                               edgewidth = 5, showqns = false,
                               linklabels = "tags",
                               fontsize = 5,
                               method = "spring",
                               edgelabel_offset = 0.0,
                               layout_kw = nothing,
                               curves = false)
  edge_index_list = contraction_graph(As...)

  if string(method) == "spring" && isnothing(layout_kw)
    layout_kw = Dict{Symbol, Any}(:C => 3.0, :iterations => 100_000)
  else
    layout_kw = Dict{Symbol, Any}()
  end

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

  p = Plots.plot()
  graphplot!(p, adjlist; arrow = true, nodeshape = :circle,
             curves = curves,
             names = names, edgewidth = edgewidths, edgelabel = edgelabels,
             edgelabel_offset = edgelabel_offset, fontsize = fontsize,
             edgelabel_box = true, method = Symbol(method),
             layout_kw = layout_kw)
  return p
end

