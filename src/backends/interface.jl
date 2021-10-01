function plot(::Val{T}, args...; kwargs...) where {T}
  return error("plot not implemented for backend type $T.")
end
function draw_edge!(::Val{T}, args...; kwargs...) where {T}
  return error("draw_edge! not implemented for backend type $T.")
end
function annotate!(::Val{T}, args...; kwargs...) where {T}
  return error("annotate! not implemented for backend type $T.")
end

function translate_color(::Val{T}, color) where {T}
  return error("translate_color not implemented for backend type $T and color $color")
end

point_to_line(v1, v2) = ([v1[1], v2[1]], [v1[2], v2[2]])

## function circleplot!(backend::Val, plot; x=0, y=0, r=1, kwargs...)
##   iszero(r) && return plot
##   ỹ(x̃) = √(abs(r^2 - (x̃ - x)^2))
##   ỹ⁺(x̃) = ỹ(x̃) + y
##   ỹ⁻(x̃) = -ỹ(x̃) + y
##   lineplot!(backend, plot, ỹ⁻, x - r, x + r; kwargs...)
##   lineplot!(backend, plot, ỹ⁺, x - r, x + r; kwargs...)
##   return plot
## end
## circleplot!(::Val{T}, args...; kwargs...) where {T} = error("circleplot! not implemented for backend type $T.")
