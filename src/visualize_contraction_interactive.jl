
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

function visualize_network_interactive(adjlist::Vector{<:Vector{<:Number}},
                                       start_points::Vector;
                                       edgewidths = 10, nodecolors = :lightblue,
                                       arrows = false, nodesize = 100)
  scene = Scene()

  nedges = sum(length, adjlist)
  npoints = length(start_points)

  points = Node(Point2f0.(start_points))

  if edgewidths isa Number
    edgewidths = fill(edgewidths, 2*nedges)
  else
    @assert length(edgewidths) == nedges
    edgewidths = collect(Iterators.flatten(zip(edgewidths, edgewidths)))
  end

  lines = Node(update_lines(adjlist, points[]))

  line_arrow_kwargs = (linewidth = edgewidths, scale_plot = false, show_axis = false)
  # Line segments
  if arrows
    shorten_arrow_scale = 370
    start, dirs = Node.(lines_to_arrows(lines[]; shorten_length = nodesize / shorten_arrow_scale))
    arrows!(scene, start, dirs; line_arrow_kwargs...)
  else
    linesegments!(scene, lines; line_arrow_kwargs...)
  end

  # Points
  GLMakie.scatter!(scene, points, color = nodecolors, strokewidth = 5, markersize = nodesize,
                   strokecolor = :black, raw = true)

  pplot = scene[end]

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
      if arrows
        start[], dirs[] = lines_to_arrows(new_lines; shorten_length = nodesize / shorten_arrow_scale)
      else
        # Update the lines with the new points
        lines[] = new_lines
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

function visualize_contraction_interactive(As::ITensor...;
                                           names = ["A$n" for n in 1:length(As)],
                                           edgewidth = 5, showqns = false,
                                           linklabels = "tags",
                                           fontsize = 5, method = "stress",
                                           edgelabel_offset = 0.0,
                                           layout_kw = Dict{Symbol,Any}(),
                                           curves = false)
  # No curves available in interactive mode
  @assert !curves

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

  # Random starting points
  #start_points = [(rand(), rand()) for _ in 1:size(adjlist, 1)]

  # Start points from NetworkLayout
  start_points = NetworkLayout.Stress.layout(get_adjacency_matrix(adjlist), 2)

  @show start_points

  scene = visualize_network_interactive(adjlist,
                                        start_points;
                                        edgewidths = 10, nodecolors = :lightblue,
                                        arrows = false, nodesize = 100)
  return scene
end

