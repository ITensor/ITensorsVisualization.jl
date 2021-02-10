using ITensors
using ITensorsVisualization

N = 10
s(n) = Index([QN("Sz", 0) => 1, QN("Sz", 1) => 1]; tags = "S=1/2,Site,n=$n")
l(n) = Index([QN("Sz", 0) => 10, QN("Sz", 1) => 10]; tags = "Link,l=$n")
h(n) = Index([QN("Sz", 0) => 5, QN("Sz", 1) => 5]; tags = "ham,Link,l=$n")
s⃗ = [s(n) for n in 1:N]
l⃗ = [l(n) for n in 1:N-1]
h⃗ = [h(n) for n in 1:N-1]

# Add some more indices between two of the tensors
x = Index([QN("Sz", 0) => 2]; tags = "X")
y = Index([QN("Sz", 0) => 2]; tags = "Y")

n = 2
ψₙₙ₊₁ = randomITensor(l⃗[n-1], s⃗[n], s⃗[n+1], l⃗[n+1], dag(x), dag(y))
hₙ = randomITensor(dag(h⃗[n-1]), s⃗[n]', dag(s⃗[n]), h⃗[n], x, y)
hₙ₊₁ = randomITensor(dag(h⃗[n]), s⃗[n+1]', dag(s⃗[n+1]), h⃗[n+1])
ELₙ₋₁ = randomITensor(l⃗[n-1]', h⃗[n-1], dag(l⃗[n-1]))
ERₙ₊₁ = randomITensor(l⃗[n+1]', dag(h⃗[n+1]), dag(l⃗[n+1]))

R = @visualize ELₙ₋₁ * ψₙₙ₊₁ * hₙ * hₙ₊₁ * ERₙ₊₁ pause = true
@show R ≈ ELₙ₋₁ * ψₙₙ₊₁ * hₙ * hₙ₊₁ * ERₙ₊₁

# Split it up into multiple contractions
R1 = @visualize ELₙ₋₁ * ψₙₙ₊₁ * hₙ pause = true
R2 = @visualize R1 * hₙ₊₁ * ERₙ₊₁ pause = true
@show R2 ≈ ELₙ₋₁ * ψₙₙ₊₁ * hₙ * hₙ₊₁ * ERₙ₊₁
