defmodule ExAlgo.Helpers do
  @moduledoc """
  Various helper functions during development and testing.
  """
  @type board :: {non_neg_integer(), any()}
  @type elem :: any()
  @type idx :: non_neg_integer()
  @type list_2d :: list(list(elem()))

  @doc """
  Prints a 2D board of the format map(tuple(idx, val)).
  """
  @spec print2d(%{required(idx()) => board()}) :: list_2d()
  def print2d(map) do
    {{min_x, min_y}, {max_x, max_y}} = map |> Map.keys() |> Enum.min_max()

    for i <- min_x..max_x do
      for j <- min_y..max_y do
        map[{i, j}]
      end
    end
  end
end
