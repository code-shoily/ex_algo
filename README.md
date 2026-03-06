# ExAlgo

`ExAlgo` is a curated collection of data structures and algorithms implemented in Elixir. This project represents an exploration of classic algorithmic patterns through the lens of functional programming and Elixir's unique primitives.

The primary goal is to serve as an educational resource for implementing algorithms in a functional context. It also serves as a repository for utility algorithms useful for challenges like Advent of Code.

> [!NOTE]
> While these implementations are verified with comprehensive tests, many of these algorithms have specialized, production-ready libraries available in the Hex ecosystem. This project is intended for learning and reference rather than as a replacement for established libraries.

## Table of Contents

- [Development](#development)
- [Detailed Documentation](#detailed-documentation)
- [Catalogue](#catalogue)
  - [Graph](#graph)
  - [Heap](#heap)
  - [List](#list)
  - [Queue](#queue)
  - [Search](#search)
  - [Set](#set)
  - [Sort](#sort)
  - [Stack](#stack)
  - [String](#string)
  - [Tree](#tree)
  - [Counting](#counting)
  - [Trie](#trie)
  - [Dynamic Programming](#dynamic-programming)
  - [Numbers](#numbers)

## Development

Download this repo and get the dependencies with `mix deps.get`. Go to `iex -S mix` to try out the algorithms in the REPL.

### Testing

- `mix test` - Run all tests
- `mix coveralls` - Run tests with coverage report
- `mix coveralls.html` - Generate HTML coverage report (opens in browser at `cover/excoveralls.html`)
- `mix coveralls.detail` - Show detailed coverage per file

### Documentation

- `mix docs` - Generate documentation
- Documentation will be available at `doc/index.html`

## Detailed Documentation

Comprehensive API documentation is available via ex_doc. After running `mix docs`, open `doc/index.html` in your browser to explore detailed documentation for all modules, including usage examples and type specifications.

## Catalogue

### Graph

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Inductive Graph Model | [model.ex](lib/ex_algo/graph/functional/model.ex) | [Yes](test/ex_algo/graph/functional/model_test.exs) | No | | Core Inductive Data Structure |
| DFS | [traversal.ex](lib/ex_algo/graph/functional/traversal.ex) | [Yes](test/ex_algo/graph/functional/traversal_test.exs) | No | | Inductive Depth-First Search |
| BFS | [traversal.ex](lib/ex_algo/graph/functional/traversal.ex) | [Yes](test/ex_algo/graph/functional/traversal_test.exs) | No | | Inductive Breadth-First Search |
| Topological Sort | [algorithms.ex](lib/ex_algo/graph/functional/algorithms.ex) | [Yes](test/ex_algo/graph/functional/algorithms_test.exs) | No | | Inductive Kahn's Algorithm |
| Dijkstra's Algorithm | [algorithms.ex](lib/ex_algo/graph/functional/algorithms.ex) | [Yes](test/ex_algo/graph/functional/algorithms_test.exs) | No | | Shortest Path |
| Prim's MST | [algorithms.ex](lib/ex_algo/graph/functional/algorithms.ex) | [Yes](test/ex_algo/graph/functional/algorithms_test.exs) | No | | Minimum Spanning Tree |
| Kosaraju's SCC | [algorithms.ex](lib/ex_algo/graph/functional/algorithms.ex) | [Yes](test/ex_algo/graph/functional/algorithms_test.exs) | No | | Strongly Connected Components |
| Connected Components | [analysis.ex](lib/ex_algo/graph/functional/analysis.ex) | [Yes](test/ex_algo/graph/functional/analysis_test.exs) | No | | Undirected Components |
| Tarjan's Connectivity | [analysis.ex](lib/ex_algo/graph/functional/analysis.ex) | [Yes](test/ex_algo/graph/functional/analysis_test.exs) | No | | Bridges & Articulation Points |
| Functional Transformations | [transform.ex](lib/ex_algo/graph/functional/transform.ex) | [Yes](test/ex_algo/graph/functional/transform_test.exs) | No | | Higher-order ops (map/filter) |
| Graph Visualizer | [visualizer.ex](lib/ex_algo/graph/functional/visualizer.ex) | [Yes](test/ex_algo/graph/functional/visualizer_test.exs) | No | | Mermaid & Inspect support |

### Heap

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Leftist Heap | [leftist_heap.ex](lib/ex_algo/heap/leftist_heap.ex) | [Yes](test/ex_algo/heap/leftist_heap_test.exs) | No | | |
| Pairing Heap | [pairing_heap.ex](lib/ex_algo/heap/pairing_heap.ex) | [Yes](test/ex_algo/heap/pairing_heap_test.exs) | No | | |

### List

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Linked List | [linked_list.ex](lib/ex_algo/list/linked_list.ex) | [Yes](test/ex_algo/list/linked_list_test.exs) | No | | |
| Circular List | [circular_list.ex](lib/ex_algo/list/circular_list.ex) | [Yes](test/ex_algo/list/circular_list_test.exs) | No | | |
| BidirectionalList | [bidirectional_list.ex](lib/ex_algo/list/bidirectional_list.ex) | [Yes](test/ex_algo/list/bidirectional_list_test.exs) | No | | WIP |
| Maximum Subarray Sum | [algorithms.ex](lib/ex_algo/list/algorithms.ex) | [Yes](test/ex_algo/list/algorithms_test.exs) | No | | Kadane's Algorithm |


### Queue

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Queue | [queue.ex](lib/ex_algo/queue/queue.ex) | [Yes](test/ex_algo/queue/queue_test.exs) | No | | |

### Search

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Binary Search | [binary_search.ex](lib/ex_algo/search/binary_search.ex) | [Yes](test/ex_algo/search/binary_search_test.exs) | No | | |

### Set

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Disjoint Set | [disjoint_set.ex](lib/ex_algo/set/disjoint_set.ex) | [Yes](test/ex_algo/set/disjoint_set_test.exs) | No | | |

### Sort

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Sort Interface | [sort.ex](lib/ex_algo/sort/sort.ex) | [No](test/ex_algo/sort/sort_test.exs) | No | | Universal sorting facade |
| Bubble Sort | [exchange.ex](lib/ex_algo/sort/exchange.ex) | [Yes](test/ex_algo/sort/exchange_test.exs) | No | | |
| Insertion Sort | [insertion.ex](lib/ex_algo/sort/insertion.ex) | [Yes](test/ex_algo/sort/insertion_test.exs) | No | | |
| Merge Sort | [merge.ex](lib/ex_algo/sort/merge.ex) | [Yes](test/ex_algo/sort/merge_test.exs) | No | | |
| Pigeonhole Sort | [distribution.ex](lib/ex_algo/sort/distribution.ex) | [Yes](test/ex_algo/sort/distribution_test.exs) | No | | |
| Quick Sort | [exchange.ex](lib/ex_algo/sort/exchange.ex) | [Yes](test/ex_algo/sort/exchange_test.exs) | No | | |
| Selection Sort | [selection.ex](lib/ex_algo/sort/selection.ex) | [Yes](test/ex_algo/sort/selection_test.exs) | No | | |

### Stack

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Stack | [stack.ex](lib/ex_algo/stack/stack.ex) | [Yes](test/ex_algo/stack/stack_test.exs) | No | | |
| Min-Max Stack | [min_max_stack.ex](lib/ex_algo/stack/min_max_stack.ex) | [Yes](test/ex_algo/stack/min_max_stack_test.exs) | No | | |

### String

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |

### Tree

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Binary Search Tree | [binary_search_tree.ex](lib/ex_algo/tree/binary_search_tree.ex) | [Yes](test/ex_algo/tree/binary_search_tree_test.exs) | No | |
| Tree Traversals | [traversal.ex](lib/ex_algo/tree/traversal.ex) | [Yes](test/ex_algo/tree/traversal_test.exs) | No | | |

### Counting

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Permutations | [combinatorics.ex::permutations](lib/ex_algo/counting/combinatorics.ex) | [Yes](test/ex_algo/counting/combinatorics_test.exs) | No | | Naive|
| Combinations | [combinatorics.ex::combinations](lib/ex_algo/counting/combinatorics.ex) | [Yes](test/ex_algo/counting/combinatorics_test.exs) | No | | Naive|

### Trie

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Prefix Trie | [prefix_trie.ex](lib/ex_algo/trie/prefix_trie.ex) | [Yes](test/ex_algo/trie/prefix_trie_test.exs) | No | | Functional map-based Trie |


### Dynamic Programming

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Subset Sum | [subset_sum.ex](lib/ex_algo/dynamic_programming/subset_sum.ex) | [Yes](test/ex_algo/dynamic_programming/subset_sum_test.exs) | No | | FIXME: Not all subsets are listed. Need to work on that. |

### Numbers

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Chinese Remainder Theorem | [chinese_remainder.ex](lib/ex_algo/number/chinese_remainder.ex) | [Yes](test/ex_algo/number/chinese_remainder_test.exs) | No | | |
| Catalan Numbers (Recursive) | [catalan.ex::recursive](lib/ex_algo/number/catalan.ex) | [Yes](test/ex_algo/number/catalan_test.exs) | No | | |
| Catalan Numbers (Dynamic) | [catalan.ex::dp](lib/ex_algo/number/catalan.ex) | [Yes](test/ex_algo/number/catalan_test.exs) | No | | |
| Divisors | [arithmetics.ex::divisors](lib/ex_algo/number/arithmetics.ex) | [Yes](test/ex_algo/number/arithmetics_test.exs) | No | | |

## AI Usage Note

Parts of this repository, including refactoring for academic alignment, documentation enhancements, and several algorithmic implementations (such as the Inductive Graph suite and Prefix Trie), were developed or refined in collaboration with an AI coding assistant (Antigravity). This partnership helped ensure consistent documentation standards, rigorous testing, and adherence to functional programming best practices.
