
# Determine the lines from the points and adjacency list
function update_lines(adjlist::Vector{Vector{Int}},
                      points::Vector{Point2f0})
  linesegment_list = Pair{Point2f0, Point2f0}[]
  for nodeᵢ in 1:length(adjlist)
    for nodeⱼ in adjlist[nodeᵢ]
      push!(linesegment_list, points[nodeᵢ] => points[nodeⱼ])
    end
  end
  return linesegment_list
end

# Convert lines to seperate vectors of starting points and directions
# for use with `arrows!`
function lines_to_arrows(lines::Vector{Pair{Point2f0, Point2f0}};
                         shorten_length = 0.0)
  start, finish = first.(lines), last.(lines)
  dirs = (finish .- start)
  lengths = norm.(dirs)
  scale_lengths = 1 .- shorten_length ./ lengths
  dirs .*= scale_lengths
  return start, dirs
end

function lines_to_edgelabelpoints(lines, shiftedgelabels = fill(Point2f0(0, 0), length(lines)))
  if shiftedgelabels isa Point
    shiftedgelabels = fill(shiftedgelabels, length(lines))
  end
  return (getindex.(lines, 2) .+ getindex.(lines, 1)) ./ 2 .+ shiftedgelabels
end

function visualize_network!(scene, adjlist::Vector{<:Vector{<:Number}},
                            start_points::Vector;
                            nodecolors = :lightblue,
                            showarrows = false,
                            nodesizes = 100,
                            nodeshape = :rect,
                            nodelabels = String[],
                            nodelabelsize = 0.2,
                            nodelabeloffset = Point2f0(0.2, 0.1),
                            nodelabelcolor = :black,
                            edgelabels = String[],
                            edgelabelsize = 0.1,
                            edgewidths = 15,
                            edgewidthsscale = 10,
                            edgelabelcolor = :red)
  nedges = sum(length, adjlist)
  npoints = length(start_points)

  points = Node(Point2f0.(start_points))

  if edgewidths isa Number
    edgewidths = fill(edgewidths, nedges)
  elseif edgewidths isa Dict
    edgewidths_vector = Float64[]
    for nodeᵢ in 1:length(adjlist)
      for nodeⱼ in adjlist[nodeᵢ]
        # In the multigraph case, the widths are multiplied
        # together to represent a tensor product
        edgewidth = 1
        n = 1
        while haskey(edgewidths, (nodeᵢ, nodeⱼ, n))
          edgewidth *= edgewidths[(nodeᵢ, nodeⱼ, n)]
          n += 1
        end
        # Include the multigraph biderectional case
        n = 1
        while haskey(edgewidths, (nodeⱼ, nodeᵢ, n))
          edgewidth *= edgewidths[(nodeⱼ, nodeᵢ, n)]
          n += 1
        end
        push!(edgewidths_vector, edgewidth)
      end
    end
    edgewidths = edgewidths_vector
  end

  @assert length(edgewidths) == nedges
  edgewidths = collect(Iterators.flatten(zip(edgewidths, edgewidths)))

  # Rescale the edgewidths
  max_edgewidths = maximum(edgewidths)
  edgewidths ./= max_edgewidths
  edgewidths .*= edgewidthsscale

  lines = Node(update_lines(adjlist, points[]))

  line_arrow_kwargs = (linewidth = edgewidths, scale_plot = false, show_axis = false)
  # Line segments
  if showarrows
    shorten_arrow_scale = 370
    # XXX: Shorten arrow by different lengths for different node sizes
    start, dirs = Node.(lines_to_arrows(lines[]; shorten_length = maximum(nodesizes) / shorten_arrow_scale))
    arrows!(scene, start, dirs; arrowsize = 0.2, line_arrow_kwargs...)
  else
    linesegments!(scene, lines; line_arrow_kwargs...)
  end

  # Points
  GLMakie.scatter!(scene, points, color = nodecolors, strokewidth = 5, markersize = nodesizes,
                   strokecolor = :black, raw = true, marker = nodeshape)

  # Node labels
  if !isempty(nodelabels)
    nodelabelpoints = Node.(points[] .- nodelabeloffset)
    for n in 1:npoints
      text!(scene, nodelabels[n]; textsize = nodelabelsize, position = nodelabelpoints[n],
            color = nodelabelcolor)
    end
  end

  # Edge labels
  if !isempty(edgelabels)
    shiftedgelabels = Point2f0(-0.4, 0.0)
    edgelabelpoints = Node.(lines_to_edgelabelpoints(lines[], shiftedgelabels))
    label_already_used = Dict{Tuple{Int, Int, Int}, Bool}()
    n = 1
    for nodeᵢ in 1:length(adjlist)
      for nodeⱼ in adjlist[nodeᵢ]
        # TODO: deal with bidirectional multigraph case
        # Handle the multigraph case by appending the labels together
        edgelabel = ""
        nrepeat = 1
        while haskey(edgelabels, (nodeᵢ, nodeⱼ, nrepeat)) && !haskey(label_already_used, (nodeᵢ, nodeⱼ, nrepeat))
          if nrepeat > 1
            edgelabel *= "\n ⊗ "
          end
          edgelabel *= edgelabels[(nodeᵢ, nodeⱼ, nrepeat)]
          label_already_used[(nodeᵢ, nodeⱼ, nrepeat)] = true
          nrepeat += 1
        end
        # Include the multigraph bidirectional case
        nrepeat = 1
        while haskey(edgelabels, (nodeⱼ, nodeᵢ, nrepeat)) && !haskey(label_already_used, (nodeⱼ, nodeᵢ, nrepeat))
          edgelabel *= "\n ⊗ "
          edgelabel *= edgelabels[(nodeⱼ, nodeᵢ, nrepeat)]
          edgelabel *= " †"
          label_already_used[(nodeⱼ, nodeᵢ, nrepeat)] = true
          nrepeat += 1
        end
        text!(scene, edgelabel; textsize = edgelabelsize,
              position = edgelabelpoints[n], color = edgelabelcolor)
        n += 1
      end
    end
  end

  pplot = scene[2]

  # This function lets you drag the points and lines around with a left click
  function add_move!(scene, points, pplot)
    idx = Ref(0); dragstart = Ref(false); startpos = Base.RefValue(Point2f0(0))
    on(events(scene).mousedrag) do drag
      if ispressed(scene, Mouse.left)
        if drag == Mouse.down
          plot, _idx = mouse_selection(scene)
          if plot == pplot
            idx[] = _idx; dragstart[] = true
            startpos[] = to_world(scene, Point2f0(scene.events.mouseposition[]))
          end
        elseif drag == Mouse.pressed && dragstart[] && checkbounds(Bool, points[], idx[])
          pos = to_world(scene, Point2f0(scene.events.mouseposition[]))
          points[][idx[]] = pos
          points[] = points[]
        end
      else
        dragstart[] = false
      end
      # Update the lines with the new points
      new_lines = update_lines(adjlist, points[])
      if showarrows
        # XXX: shorten arrows by different lengths for different node sizes
        start[], dirs[] = lines_to_arrows(new_lines; shorten_length = maximum(nodesizes) / shorten_arrow_scale)
      else
        # Update the lines with the new points
        lines[] = new_lines
      end
      # Update the text with the new points
      for n in 1:npoints
        nodelabelpoints[n][] = points[][n] - nodelabeloffset
      end
      new_edgelabelpoints = lines_to_edgelabelpoints(new_lines, shiftedgelabels)
      for n in 1:length(edgelabelpoints)
        edgelabelpoints[n][] = new_edgelabelpoints[n]
      end
      return
    end
  end

  add_move!(scene, points, pplot)

  center!(scene)

  # Do not execute beyond this point!
  RecordEvents(scene, "output")

  return scene
end

function visualize_tensornetwork(As::ITensor...;
                                 labels = ["T$n" for n in 1:length(As)],
                                 showtags = true,
                                 showplevs = true,
                                 showids = true,
                                 showdims = true,
                                 showqns = false,
                                 fontsize = 5,
                                 method = "spring",
                                 edgelabel_offset = 0.0,
                                 showarrows = all(hasqns, As),
                                 layout_kw = Dict{Symbol,Any}(),
                                 scene = Scene())
  if length(As) ≠ length(labels)
    error("Number of tensor labels $labels does not match the number of tensors $(length(As)).")
  end

  edge_index_list = contraction_graph(As...)

  #
  # Compute the adjacency matrix/list
  #

  adjlist = get_adjacency_list(edge_index_list)
  #adjmatrix = get_adjacency_matrix(edge_index_list)

  #
  # Determine the edge widths from the Index dimensions
  # These will be scaled in visualize_network_interactive
  #

  edgewidths = Dict{Tuple{Int, Int, Int}, Float64}()
  dimprods = Int[]
  for edge in keys(edge_index_list)
    inds = edge_index_list[edge]
    dimprod = 1
    for nind in 1:length(inds)
      dim_ind = dim(inds[nind])
      edgewidths[(edge..., nind)] = dim_ind
      dimprod *= dim_ind
    end
    push!(dimprods, dimprod)
  end

  #
  # Determine the edge labels from the Index tags, etc.
  #

  edgelabels = Dict{Tuple{Int, Int, Int}, String}()
  for edge in keys(edge_index_list)
    inds = edge_index_list[edge]
    for nind in 1:length(inds)
      ind = inds[nind]

      label = "("
      if showdims
        label *= "dim=$(dim(ind))|"
      end
      if showids
        label *= "id=$(id(ind) % 1000)|"
      end
      if showtags
        label *= string(tags(ind))
      end
      label *= ")"
      if showplevs
        label *= ITensors.primestring(plev(ind))
      end
      if showqns
        label *= "\n"
        for (n, qnblock) in enumerate(space(ind))
          label *= " $n: $qnblock"
          if n < length(space(ind))
            label *= "\n"
          end
        end
      end

      edgelabels[(edge..., nind)] = label
    end
  end

  # Random starting points
  #start_points = [(rand(), rand()) for _ in 1:size(adjlist, 1)]

  adjacency_matrix = get_adjacency_matrix(adjlist)

  # Start points from NetworkLayout
  start_points = if method == "random"
    map(x -> 2 .* rand(Point{2, Float64}) .- 1, 1:size(adjacency_matrix, 1))
  elseif method == "stress"
    NetworkLayout.Stress.layout(adjacency_matrix, 2; iterations = 10_000_000)
  elseif method == "sfdp"
    NetworkLayout.SFDP.layout(adjacency_matrix, 2)
  elseif method == "spring"
    NetworkLayout.Spring.layout(adjacency_matrix, 2; C = 1.75, iterations = 100_000)
  else
    error("Network layout method $method not supported")
  end

  #
  # Node labels are labels of the tensors
  # By default, make labels of site nodes empty
  #

  ntensors = length(As)
  nsites = size(adjlist, 1) - ntensors

  labels = String[labels...]
  append!(labels, fill("", nsites))

  nodes = fill(:rect, ntensors)
  append!(nodes, fill(:circle, nsites))

  nodesizes = fill(100, ntensors)
  append!(nodesizes, fill(25, nsites))

  nodecolors = fill(:lightblue, ntensors)
  append!(nodecolors, fill(:white, nsites))

  visualize_network!(scene, adjlist,
                     start_points;
                     nodecolors = nodecolors,
                     showarrows = showarrows,
                     nodeshape = nodes,
                     nodesizes = nodesizes,
                     nodelabels = labels,
                     edgelabels = edgelabels,
                     edgewidths = edgewidths)
  return scene
end

