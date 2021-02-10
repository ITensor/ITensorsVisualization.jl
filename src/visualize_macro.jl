
# Visualize a contraction and then perform the contraction
function contract_visualize(As::ITensor...; kwargs...)
  scene = visualize_tensornetwork(As...; kwargs...)
  display(scene)
  return *(As...)
end

expr_to_string(s::Symbol) = String(s)
expr_to_string(ex::Expr) = String(repr(ex))[3:end-1]

macro visualize(ex, kwargs...)
  # Must be a tensor contraction
  @assert ex.args[1] == :*
  x = [esc(a) for a in kwargs]
  return :(contract_visualize($(esc.(ex.args[2:end])...); $(x...), names = expr_to_string.($(ex.args[2:end]))))
end

