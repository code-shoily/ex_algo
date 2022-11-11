# ExAlgo

`ExAlgo` is a collection of data structures and algorithms implemented in Elixir. This is the authors attempt to see algorithms through Elixir's lens.

The sole purpose of this is to use as a learning tool for algorithms in a functional language set-up. I am also thinking of using this to host some algorithms that could come in handy while solving Advent of Code. Almost all algorithms mentioned here have well tested and production ready libraries so I see little use that anyone would want to use this for anything serious.

## Development

Download this repo and get the dependencies with `mix deps.get`. Go to `iex -S mix` to try out the algorithms in the REPL. `mix test` runs all the tests.

## Detailed Documentation

TODO - Add ex_doc pages with detailed explanations of each categories.

## Catalogue

### Graph

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |

### Heap

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |

### List

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Linked List | [linked_list.ex](lib/ex_algo/list/linked_list.ex) | [Yes](test/ex_algo/list/linked_list_test.exs) | No | | |
| Circular List | [circular_list.ex](lib/ex_algo/list/circular_list.ex) | [Yes](test/ex_algo/list/circular_list_test.exs) | No | | |
| BidirectionalList | [bidirectional_list.ex](lib/ex_algo/list/bidirectional_list.ex) | [Yes](test/ex_algo/list/bidirectional_list_test.exs) | No | | WIP |
| Maximum Subarray Sum | [algorithms.ex](lib/ex_algo/list/algorithms.ex) | [Yes](test/ex_algo/list/algorithms_test.exs) | No | | Kadane's Algorithm |

### Functional/Immutable

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |

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

### Trie

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Permutations | [combinatorics.ex::permutations](lib/ex_algo/counting/combinatorics.ex) | [Yes](test/ex_algo/counting/combinatorics_test.exs) | No | | Naive|
| Combinations | [combinatorics.ex::combinations](lib/ex_algo/counting/combinatorics.ex) | [Yes](test/ex_algo/counting/combinatorics_test.exs) | No | | Naive|

### Counting

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |

### Dynamic Programming

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Subset Sum | [subset_sum.ex](lib/ex_algo/dynamic_programming/subset_sum.ex) | [Yes](test/ex_algo/dynamic_programming/subset_sum_test.exs) | No | | |

### Numbers

| Name | Implementation | Test | Benchmark | Link | Note |
| :--: | :------------: | :--: | :-------: | :--: | :--: |
| Chinese Remainder Theorem | [chinese_remainder.ex](lib/ex_algo/number/chinese_remainder.ex) | [Yes](test/ex_algo/number/chinese_remainder_test.exs) | No | | |
| Catalan Numbers (Recursive) | [catalan.ex::recursive](lib/ex_algo/number/catalan.ex) | [Yes](test/ex_algo/number/catalan_test.exs) | No | | |
| Catalan Numbers (Dynamic) | [catalan.ex::dp](lib/ex_algo/number/catalan.ex) | [Yes](test/ex_algo/number/catalan_test.exs) | No | | |
| Divisors | [arithmetics.ex::divisors](lib/ex_algo/number/arithmetics.ex) | [Yes](test/ex_algo/number/arithmetics_test.exs) | No | | |
