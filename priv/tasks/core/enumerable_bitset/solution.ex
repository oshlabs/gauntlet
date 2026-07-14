defmodule BitSet do
  defstruct bits: 0

  def new, do: %__MODULE__{}

  def new(enum) do
    Enum.reduce(enum, new(), &put(&2, &1))
  end

  def put(%__MODULE__{bits: bits}, n) when is_integer(n) and n >= 0 do
    %__MODULE__{bits: Bitwise.bor(bits, Bitwise.bsl(1, n))}
  end

  def member?(%__MODULE__{bits: bits}, n) when is_integer(n) and n >= 0 do
    Bitwise.band(Bitwise.bsr(bits, n), 1) == 1
  end

  def member?(%__MODULE__{}, _n), do: false

  defimpl Enumerable do
    def count(%BitSet{bits: bits}), do: {:ok, popcount(bits, 0)}

    def member?(%BitSet{} = set, n), do: {:ok, BitSet.member?(set, n)}

    def slice(%BitSet{}), do: {:error, __MODULE__}

    def reduce(_set, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(set, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(set, &1, fun)}

    def reduce(%BitSet{bits: 0}, {:cont, acc}, _fun), do: {:done, acc}

    def reduce(%BitSet{bits: bits}, {:cont, acc}, fun) do
      # lowest set bit
      lsb = Bitwise.band(bits, -bits)
      n = bit_index(lsb, 0)
      rest = %BitSet{bits: Bitwise.bxor(bits, lsb)}
      reduce(rest, fun.(n, acc), fun)
    end

    defp popcount(0, acc), do: acc

    defp popcount(bits, acc),
      do: popcount(Bitwise.band(bits, bits - 1), acc + 1)

    defp bit_index(1, idx), do: idx
    defp bit_index(lsb, idx), do: bit_index(Bitwise.bsr(lsb, 1), idx + 1)
  end
end
