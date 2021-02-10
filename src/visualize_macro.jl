
const continues = ["c", "Continue", "C", "continue"]

function c_to_continue()
  while true
    println("Press C/c and then Enter to continue:")
    ans = readline()
    ans ∈ continues && return
  end
end

# Visualize a contraction and then perform the contraction
function contract_visualize(As::ITensor...; pause = false, kwargs...)
  scene = visualize_tensornetwork(As...; kwargs...)
  display(scene)
  if pause
    c_to_continue()
  end
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

