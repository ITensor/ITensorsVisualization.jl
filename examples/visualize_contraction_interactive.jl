using ITensors
using ITensorsVisualization

N = 10
s(n) = Index([QN("Sz", 0) => 1, QN("Sz", 1) => 1]; tags = "S=1/2,Site,n=$n")
l(n) = Index([QN("Sz", 0) => 10, QN("Sz", 1) => 10]; tags = "Link,l=$n")
h(n) = Index([QN("Sz", 0) => 5, QN("Sz", 1) => 5]; tags = "ham,Link,l=$n")
s⃗ = [s(n) for n in 1:N]
l⃗ = [l(n) for n in 1:N-1]
h⃗ = [h(n) for n in 1:N-1]

# Add a multiindex
x = Index([QN("Sz", 0) => 2]; tags = "X")
y = Index([QN("Sz", 0) => 2]; tags = "Y")

n = 2
ψₙₙ₊₁ = randomITensor(l⃗[n-1], s⃗[n], s⃗[n+1], l⃗[n+1], dag(x), dag(y))
hₙ = randomITensor(dag(h⃗[n-1]), s⃗[n]', dag(s⃗[n]), h⃗[n], x, y)
hₙ₊₁ = randomITensor(dag(h⃗[n]), s⃗[n+1]', dag(s⃗[n+1]), h⃗[n+1])
ELₙ₋₁ = randomITensor(l⃗[n-1]', h⃗[n-1], dag(l⃗[n-1]))
ERₙ₊₁ = randomITensor(l⃗[n+1]', dag(h⃗[n+1]), dag(l⃗[n+1]))

tensors = [ELₙ₋₁, ψₙₙ₊₁, hₙ, hₙ₊₁, ERₙ₊₁]
names = ["ELₙ₋₁", "ψₙₙ₊₁", "hₙ", "hₙ₊₁", "ERₙ₊₁"]
scene = visualize_contraction_interactive(tensors...; names = names,
                                          showid = true, showdim = true,
                                          showqns = true)

# To save the plot:
#using ITensorsVisualization.GLMakie
#scene.center = false
#save("tensor_network_interactive.jpeg", scene)

