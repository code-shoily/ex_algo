defmodule ExAlgoTest do
  use ExUnit.Case
  doctest ExAlgo

  test "greets the world" do
    assert ExAlgo.hello() == :algorithms
  end
end
