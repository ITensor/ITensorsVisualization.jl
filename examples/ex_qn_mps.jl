using ITensors
using ITensorsVisualization
using GLMakie

s = siteinds("S=1/2", 5; conserve_qns=true)
ψ = randomMPS(s, n -> isodd(n) ? "↑" : "↓"; linkdims=2)
orthogonalize!(ψ, 2)
ψdag = prime(linkinds, dag(ψ))
tn = [ψ..., ψdag...]

@visualize fig tn show_qns=true show_plevs=true edge_textsize=20 backend="Makie"

fig
