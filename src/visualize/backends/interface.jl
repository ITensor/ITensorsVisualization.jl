lineplot(::Val{T}, args...; kwargs...) where {T} = error("lineplot not implemented for backend type $T.")
lineplot!(::Val{T}, args...; kwargs...) where {T} = error("lineplot! not implemented for backend type $T.")
annotate!(::Val{T}, args...; kwargs...) where {T} = error("annotate! not implemented for backend type $T.")

function circleplot!(backend::Val, plot; x=0, y=0, r=1, kwargs...)
  iszero(r) && return plot
  ỹ(x̃) = √(abs(r^2 - (x̃ - x)^2))
  ỹ⁺(x̃) = ỹ(x̃) + y
  ỹ⁻(x̃) = -ỹ(x̃) + y
  lineplot!(backend, plot, ỹ⁻, x - r, x + r; kwargs...)
  lineplot!(backend, plot, ỹ⁺, x - r, x + r; kwargs...)
  return plot
end
circleplot!(::Val{T}, args...; kwargs...) where {T} = error("circleplot! not implemented for backend type $T.")
