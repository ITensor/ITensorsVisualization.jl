using ITensors
using ITensorsVisualization

if isempty(ARGS)
  error("Specify whether or not you want to pause after each visualization with the first command line argument or with `push!(ARGS, \"true\")` or `push!(ARGS, \"false\")`")
end
pause = parse(Bool, ARGS[1])

N = 10
sites(n) = Index([QN("Sz", 0) => 1, QN("Sz", 1) => 1]; tags="S=1/2,Site,n=$n")
l(n) = Index([QN("Sz", 0) => 10, QN("Sz", 1) => 10]; tags="Link,l=$n")
h(n) = Index([QN("Sz", 0) => 5, QN("Sz", 1) => 5]; tags="ham,Link,l=$n")
s⃗ = [sites(n) for n in 1:N]
l⃗ = [l(n) for n in 1:(N - 1)]
h⃗ = [h(n) for n in 1:(N - 1)]

# Add some more indices between two of the tensors
x = Index([QN("Sz", 0) => 2]; tags="X")
y = Index([QN("Sz", 0) => 2]; tags="Y")

n = 2
ψn1n2 = randomITensor(l⃗[n - 1], s⃗[n], s⃗[n + 1], l⃗[n + 1], dag(x), dag(y))
hn1 = randomITensor(dag(h⃗[n - 1]), s⃗[n]', dag(s⃗[n]), h⃗[n], x, y)
hn2 = randomITensor(dag(h⃗[n]), s⃗[n + 1]', dag(s⃗[n + 1]), h⃗[n + 1])
ELn0 = randomITensor(l⃗[n - 1]', h⃗[n - 1], dag(l⃗[n - 1]))
ERn2 = randomITensor(l⃗[n + 1]', dag(h⃗[n + 1]), dag(l⃗[n + 1]))

vertex = (size=50,)
show = (plev=true,)

original_backend = ITensorsVisualization.set_backend!("UnicodePlots")

R = @visualize ELn0 * ψn1n2 * hn1 * hn2 * ERn2 show=show vertex=vertex pause=pause
@show R ≈ ELn0 * ψn1n2 * hn1 * hn2 * ERn2

# Split it up into multiple contractions
R1 = @visualize ELn0 * ψn1n2 * hn1 show=show vertex=vertex pause=pause
R2 = @visualize R1 * hn2 * ERn2 show=show vertex=vertex pause=pause
@show R2 ≈ ELn0 * ψn1n2 * hn1 * hn2 * ERn2

ITensorsVisualization.set_backend!(original_backend)
