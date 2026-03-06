defmodule ExAlgo.Trie.PrefixTrieTest do
  use ExUnit.Case, async: true
  alias ExAlgo.Trie.PrefixTrie

  describe "PrefixTrie" do
    test "new/0 returns an empty map" do
      assert PrefixTrie.new() == %{}
    end

    test "insert/2 and exists?/2 work for simple strings" do
      trie =
        PrefixTrie.new()
        |> PrefixTrie.insert("apple")
        |> PrefixTrie.insert("app")

      assert PrefixTrie.exists?(trie, "apple")
      assert PrefixTrie.exists?(trie, "app")
      refute PrefixTrie.exists?(trie, "appl")
      refute PrefixTrie.exists?(trie, "ap")
      refute PrefixTrie.exists?(trie, "banana")
    end

    test "insert/2 and exists?/2 work with UTF-8 characters" do
      trie =
        PrefixTrie.new()
        |> PrefixTrie.insert("你好")
        |> PrefixTrie.insert("😀")

      assert PrefixTrie.exists?(trie, "你好")
      assert PrefixTrie.exists?(trie, "😀")
      refute PrefixTrie.exists?(trie, "你")
    end

    test "starts_with?/2 works correctly" do
      trie =
        PrefixTrie.new()
        |> PrefixTrie.insert("application")
        |> PrefixTrie.insert("apple")
        |> PrefixTrie.insert("banana")

      assert PrefixTrie.starts_with?(trie, "app")
      assert PrefixTrie.starts_with?(trie, "applic")
      assert PrefixTrie.starts_with?(trie, "ban")
      assert PrefixTrie.starts_with?(trie, "banana")
      assert PrefixTrie.starts_with?(trie, "")

      refute PrefixTrie.starts_with?(trie, "bat")
      refute PrefixTrie.starts_with?(trie, "applice")
    end
  end
end
