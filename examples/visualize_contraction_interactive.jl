using ITensors
using ITensorsVisualization

import ITensorsVisualization: visualize_contraction_interactive

N = 10
s(n) = Index([QN("Sz", 0) => 1, QN("Sz", 1) => 1]; tags = "S=1/2,Site,n=$n")
l(n) = Index([QN("Sz", 0) => 3, QN("Sz", 1) => 3]; tags = "Link,l=$n")
h(n) = Index([QN("Sz", 0) => 2, QN("Sz", 1) => 2]; tags = "ham,Link,l=$n")
s⃗ = [s(n) for n in 1:N]
l⃗ = [l(n) for n in 1:N-1]
h⃗ = [h(n) for n in 1:N-1]

x = Index(2, "x")

n = 2
ψₙₙ₊₁ = randomITensor(l⃗[n-1], s⃗[n], s⃗[n+1], l⃗[n+1])
hₙ = randomITensor(dag(h⃗[n-1]), s⃗[n]', dag(s⃗[n]), h⃗[n], x)
hₙ₊₁ = randomITensor(dag(h⃗[n]), s⃗[n+1]', dag(s⃗[n+1]), h⃗[n+1], dag(x))
ELₙ₋₁ = randomITensor(l⃗[n-1]', h⃗[n-1], dag(l⃗[n-1]))
ERₙ₊₁ = randomITensor(l⃗[n+1]', dag(h⃗[n+1]), dag(l⃗[n+1]))

contract_tensors = (ELₙ₋₁, ψₙₙ₊₁, hₙ, hₙ₊₁, ERₙ₊₁)
names = ["ELₙ₋₁", "ψₙₙ₊₁", "hₙ", "hₙ₊₁", "ERₙ₊₁"]
scene = visualize_contraction_interactive(contract_tensors...;
                                          names = names, edgewidth = 5)

#scene.center = false
#save("tensor_network_interactive.pdf", scene)

