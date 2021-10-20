using AbstractTrees
using Graphs
using ITensors
using ITensorsVisualization
using GLMakie

ITensorsVisualization.set_backend!("GLMakie")

N = 5
g = Graph(N, N)
A = itensornetwork(g; linkspaces=5)
labels = ["T$n" for n in 1:N]
sequence = Any[5, Any[Any[1, 2], Any[3, 4]]]

display(Tree(sequence))

function _contract(label1::String, label2::String)
  return string("(", label1, "*", label2, ")")
end

function _contract(tensor1::ITensor, tensor2::ITensor)
  return ITensor(noncommoninds(tensor1, tensor2))
end

sequence_traversal(sequence) = reverse(collect(StatelessBFS(sequence)))

function contract_dict(tensors, sequence, traversal=sequence_traversal(sequence))
  net_tensors = Dict()
  traversal = reverse(collect(StatelessBFS(sequence)))
  for net in traversal
    if net isa Int
      net_tensors[net] = tensors[net]
    else # net isa Vector
      net_tensors[net] = _contract(net_tensors[net[1]], net_tensors[net[2]])
    end
  end
  return net_tensors
end

# Return all of the contractions involved in the sequence.
function contraction_sequence(
  tensors,
  sequence,
  traversal=sequence_traversal(sequence),
  contract_dict=contract_dict(tensors, sequence, traversal),
)
  all_tensors = Any[]
  tensors_1 = Vector{Union{Nothing,eltype(tensors)}}(tensors)
  net_position = Dict()
  n = N + 1
  for net in traversal
    if net isa Int
      net_position[net] = net
    else
      net_position[net] = n
      n += 1
    end
    if !isa(net, Int)
      for n in net
        tensors_1[net_position[n]] = nothing
      end
      push!(tensors_1, contract_dict[net])
      push!(all_tensors, copy(tensors_1))
    end
  end
  return convert.(Vector{eltype(tensors)}, filter.(!isnothing, all_tensors))
end

traversal = sequence_traversal(sequence)
labels_sequence = contraction_sequence(labels, sequence, traversal)
tensors_sequence = contraction_sequence(A, sequence, traversal)
display(labels_sequence)

nothing
