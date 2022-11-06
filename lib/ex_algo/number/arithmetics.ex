defmodule ExAlgo.Number.Arithmetics do
  @moduledoc """
  Algorithms related to arithmetics operations
  """
  @doc """
  Returns a list of divisors of a number.

  ## Example

    iex> Arithmetics.divisors(0)
    :error

    iex> Arithmetics.divisors(1)
    [1]

    iex> Arithmetics.divisors(12)
    [1, 12, 2, 6, 3, 4]

    iex> Arithmetics.divisors(13)
    [1, 13]

  """
  def divisors(0), do: :error

  def divisors(n) do
    1..trunc(:math.sqrt(n))
    |> Enum.flat_map(fn
      x when rem(n, x) != 0 -> []
      x when x != div(n, x) -> [x, div(n, x)]
      x -> [x]
    end)
  end
end
