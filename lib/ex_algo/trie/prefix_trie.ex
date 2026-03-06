defmodule ExAlgo.Trie.PrefixTrie do
  @moduledoc """
  A functional implementation of a Prefix Trie (Digital Tree).

  A trie is an ordered tree-like data structure used to store a dynamic set or
  associative array where the keys are usually strings. Unlike a binary search
  tree, no node in the tree stores the key associated with that node; instead,
  its position in the tree defines the key with which it is associated.

  This implementation uses nested maps where each key is a single UTF-8 character,
  and a special `@terminator` key indicates the end of a valid word.
  """

  @terminator :end_of_word

  @doc """
  Creates a new empty prefix trie.
  """
  def new(), do: %{}

  @doc """
  Inserts a word into the trie.
  """
  def insert(trie, ""), do: Map.put(trie, @terminator, true)

  def insert(trie, <<char::utf8, rest::binary>>) do
    # Get the existing branch or start a new map
    child_node = Map.get(trie, <<char::utf8>>, %{})

    # Recursively update and put it back into the current level
    Map.put(trie, <<char::utf8>>, insert(child_node, rest))
  end

  @doc """
  Checks if a word exists in the trie.
  """
  def exists?(trie, ""), do: Map.has_key?(trie, @terminator)

  def exists?(trie, <<char::utf8, rest::binary>>) do
    case Map.get(trie, <<char::utf8>>) do
      nil -> false
      child_node -> exists?(child_node, rest)
    end
  end

  @doc """
  Checks if any word in the trie starts with the given prefix.
  """
  def starts_with?(_trie, ""), do: true

  def starts_with?(trie, <<char::utf8, rest::binary>>) do
    case Map.get(trie, <<char::utf8>>) do
      nil -> false
      child_node -> starts_with?(child_node, rest)
    end
  end
end
