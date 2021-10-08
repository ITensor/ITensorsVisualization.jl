using ITensors
using ITensorsVisualization
using GLMakie

ITensorsVisualization.set_backend!("Makie")

s = siteinds("S=1/2", 5; conserve_qns=true)
ψ = randomMPS(s, n -> isodd(n) ? "↑" : "↓"; linkdims=2)
orthogonalize!(ψ, 2)
ψdag = prime(linkinds, dag(ψ))
tn = [ψ..., ψdag...]

@visualize tn show=(qns=true, plevs=true) edge=(textsize=20,)
