using LightGraphs

is_grid(g::AbstractGraph; dim, periodic=false) = is_grid(Val(dim), Val(periodic), g)

is_corner(::Val{1}, g::AbstractGraph, v) = length(neighbors(g, v)) == 1
is_bulk(::Val{1}, g::AbstractGraph, v) = length(neighbors(g, v)) == 2

function findfirst_corner(d::Val{1}, g::AbstractGraph)
  return findfirst(v -> is_corner(d, g, v), vertices(g))
end

function is_grid(dim::Val{1}, periodic::Val{true}, g::AbstractGraph)
  # Must be connected
  !is_connected(g) && return false
  # Must have number of edges equal to number of vertices
  ne(g) ≠ nv(g) && return false
  for v in vertices(g)
    if !is_bulk(dim, g, v)
      return false
    end
  end
  return true
end

# Non-periodic
function is_grid(dim::Val{1}, periodic::Val{false}, g::AbstractGraph)
  # Must be connected
  !is_connected(g) && return false
  # Must have number of edges one less than
  # number of vertices
  ne(g) ≠ nv(g) - 1 && return false
  ncorners = 0
  for v in vertices(g)
    if is_corner(dim, g, v)
      ncorners += 1
      if ncorners > 2
        return false
      end
    elseif !is_bulk(dim, g, v)
      return false
    end
  end
  return true
end

function grid_positions(g::AbstractGraph; dim, periodic=false, v_src=nothing)
  return grid_positions(Val(dim), Val(periodic), g; v_src)
end

is_tree(g::AbstractGraph) = (ne(g) == nv(g) - 1) && is_connected(g)

function grid_positions(dim::Val{1}, periodic::Val{false}, g::AbstractGraph; v_src=nothing)
  # Check the graph is a tree first
  !is_tree(g) && return nothing

  pos = Vector{Int}(undef, nv(g))

  if isnothing(v_src)
    v_src = findfirst_corner(dim, g)
  else
    !is_corner(dim, g, v_src) && return nothing
  end
  isnothing(v_src) && return nothing
  num_vertices_found = 1
  pos[v_src] = num_vertices_found

  v_dst = neighbors(g, v_src)[]
  num_vertices_found = 2
  v_src, v_src_prev = v_dst, v_src
  pos[v_src] = num_vertices_found
  !is_bulk(dim, g, v_src) && return nothing

  for num_vertices_found in 3:nv(g)
    v_dst = filter(≠(v_src_prev), neighbors(g, v_src))[]
    v_src, v_src_prev = v_dst, v_src
    pos[v_src] = num_vertices_found
    if num_vertices_found == nv(g)
      !is_corner(dim, g, v_src) && return nothing
    else
      !is_bulk(dim, g, v_src) && return nothing
    end
  end

  return pos
end

function grid_positions(dim::Val{1}, periodic::Val{true}, g::AbstractGraph; v_src=nothing)
  is_tree(g) && return nothing
  ne(g) ≠ nv(g) && return nothing
  pos = Vector{Int}(undef, nv(g))
  if isnothing(v_src)
    v_src = first(vertices(g))
  end
  !is_bulk(dim, g, v_src) && return nothing
  num_vertices_found = 1
  pos[v_src] = num_vertices_found

  # Choose one of the neighbors at random
  v_dst = first(neighbors(g, v_src))
  num_vertices_found = 2
  v_src, v_src_prev = v_dst, v_src
  pos[v_src] = num_vertices_found
  !is_bulk(dim, g, v_src) && return nothing

  for num_vertices_found in 3:nv(g)
    v_dst = filter(≠(v_src_prev), neighbors(g, v_src))[]
    v_src, v_src_prev = v_dst, v_src
    pos[v_src] = num_vertices_found
    !is_bulk(dim, g, v_src) && return nothing
  end

  return pos
end

g = grid((4,); periodic=false)
@show grid_positions(g; dim=1)
@show grid_positions(g; dim=1, v_src=nv(g))
@show grid_positions(g; dim=1, v_src=2)

g = grid((4,); periodic=true)
@show grid_positions(g; dim=1, periodic=true)
@show grid_positions(g; dim=1, v_src=nv(g), periodic=true)
@show grid_positions(g; dim=1, v_src=2, periodic=true)
