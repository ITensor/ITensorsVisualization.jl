struct Backend{backend} end

Backend(b::Backend) = b
Backend(s::AbstractString) = Backend{Symbol(s)}()
Backend(s::Symbol) = Backend{s}()
backend(::Backend{N}) where {N} = N

macro Backend_str(s)
  return Backend{Symbol(s)}
end

const current_backend = Ref{Union{Nothing,Backend}}(nothing)

set_backend!(backend::Backend) = (current_backend[] = backend)
set_backend!(backend::Union{Symbol,String}) = set_backend!(Backend(backend))
get_backend() = current_backend[]

function plot(::Backend{T}, args...; kwargs...) where {T}
  return error("plot not implemented for backend type $T.")
end
function draw_edge!(::Backend{T}, args...; kwargs...) where {T}
  return error("draw_edge! not implemented for backend type $T.")
end
function annotate!(::Backend{T}, args...; kwargs...) where {T}
  return error("annotate! not implemented for backend type $T.")
end

function translate_color(::Backend{T}, color) where {T}
  return error("translate_color not implemented for backend type $T and color $color")
end

point_to_line(v1, v2) = ([v1[1], v2[1]], [v1[2], v2[2]])

## function circleplot!(backend::Backend, plot; x=0, y=0, r=1, kwargs...)
##   iszero(r) && return plot
##   ỹ(x̃) = √(abs(r^2 - (x̃ - x)^2))
##   ỹ⁺(x̃) = ỹ(x̃) + y
##   ỹ⁻(x̃) = -ỹ(x̃) + y
##   lineplot!(backend, plot, ỹ⁻, x - r, x + r; kwargs...)
##   lineplot!(backend, plot, ỹ⁺, x - r, x + r; kwargs...)
##   return plot
## end
## circleplot!(::Backend{T}, args...; kwargs...) where {T} = error("circleplot! not implemented for backend type $T.")
