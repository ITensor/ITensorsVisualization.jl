using ITensors

function unicode_visualization(
  tn::Vector{ITensor};
  edgelabels=[],
  nodelabels=[],
  nodeshapes="●", # ●, ▶, ◀, ■, █, ◩, ◪, ⧄, ⧅, ⦸, ⊘, ⬔, ⬕, ⬛, ⬤, 🔲, 🔳, 🔴, 🔵, ⚫
  edgeshapes="—", # ⇵, ⇶, ⇄, ⇅, ⇆, ⇇, ⇈, ⇉, ⇊, ⬱, —, –, ⟵, ⟶, ➖, −, ➡, ⬅, ⬆, ⬇
)
  @assert length(tn) == 2
  n1, n2 = 1, 2
  indsⁿ¹ = uniqueinds(tn[n1])
  indsⁿ² = uniqueinds(tn[n2])
  indsⁿ¹ⁿ² = commoninds(tn[n1], tn[n2])
  @show indsⁿ¹
  @show indsⁿ²
  @show indsⁿ¹ⁿ²
  mat = Char[
    '●' '—' '●'
    '|' ' ' '|'
  ]
  for r in axes(mat, 1)
    print("\n")
    for x in @view mat[r, :]
      print(x)
    end
  end
end

i = Index(2)
j = Index(3)
k = Index(4)
A = randomITensor(i, dag(j))
B = randomITensor(j, dag(k))
tn = [A, B]
unicode_visualization(tn)
