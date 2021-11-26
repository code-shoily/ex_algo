defmodule ExAlgo.Sort do
  @moduledoc """
  Implementation of various sorting algorithms.
  """
  alias __MODULE__.{Distribution, Exchange, Insertion, Merge}

  defdelegate bubble_sort(list), to: Exchange, as: :bubble_sort
  defdelegate insertion_sort(list), to: Insertion, as: :insertion_sort
  defdelegate merge_sort(list), to: Merge, as: :merge_sort
  defdelegate pigeonhole_sort(list), to: Distribution, as: :pigeonhole_sort
  defdelegate quick_sort(list), to: Exchange, as: :quick_sort
end
