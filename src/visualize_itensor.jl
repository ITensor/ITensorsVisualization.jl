function visualize(g::AbstractGraph; backend=get_backend(), kwargs...)
  return visualize(Backend(backend), g; kwargs...)
end

function visualize(tn::Vector{ITensor}; kwargs...)
  return visualize(MetaDiGraph(tn); kwargs...)
end
visualize(ψ::MPS; kwargs...) = visualize(data(ψ); kwargs...)
visualize(tn::Tuple{Vararg{ITensor}}; kwargs...) = visualize(collect(tn); kwargs...)
visualize(tn::ITensor...; kwargs...) = visualize(collect(tn); kwargs...)
