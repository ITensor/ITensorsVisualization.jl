using GLMakie
using ITensors
using ITensorsVisualization
using ReferenceTests
using Test

backends = ["UnicodePlots", "Makie"]
extensions = ["txt", "png"]
@testset "Basic test for $(backends[n])" for n in eachindex(backends)
  backend = backends[n]
  extension = extensions[n]

  N = 10
  s(n) = Index([QN("Sz", 0) => 1, QN("Sz", 1) => 1]; tags="S=1/2,Site,n=$n")
  l(n) = Index([QN("Sz", 0) => 10, QN("Sz", 1) => 10]; tags="Link,l=$n")
  h(n) = Index([QN("Sz", 0) => 5, QN("Sz", 1) => 5]; tags="ham,Link,l=$n")
  s⃗ = [s(n) for n in 1:N]
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

  R = @visualize ELn0 * ψn1n2 * hn1 * hn2 * ERn2 backend=backend
  R1 = @visualize ELn0 * ψn1n2 * hn1 backend=backend
  R2 = @visualize R1 * hn2 * ERn2 vertex=(labels=["T1", "T2", "T3"],) backend=backend

  tn = [ELn0, ψn1n2, hn1, hn2, ERn2]
  tn2 = @visualize tn backend=backend


  @test R ≈ ELn0 * ψn1n2 * hn1 * hn2 * ERn2
  @test R1 ≈ ELn0 * ψn1n2 * hn1
  @test R2 ≈ ELn0 * ψn1n2 * hn1 * hn2 * ERn2
  @test all(tn .== tn2)

  sceneR = @visualize ELn0 * ψn1n2 * hn1 * hn2 * ERn2 backend=backend execute=false
  sceneR1 = @visualize ELn0 * ψn1n2 * hn1 backend=backend execute=false
  sceneR2 = @visualize R1 * hn2 * ERn2 vertex=(labels=["T1", "T2", "T3"],) backend=backend execute=false

  scene_tn = @visualize tn backend=backend execute=false

  @test_reference "references/R.$extension" sceneR
  @test_reference "references/R1.$extension" sceneR1
  @test_reference "references/R2.$extension" sceneR2
  @test_reference "references/tn.$extension" scene_tn

  @test_throws DimensionMismatch @visualize R1 * hn2 * ERn2 vertex=(labels=["T1", "T2"],) backend=backend
end
