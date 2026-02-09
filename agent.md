# ExAlgo Coding Style Guide

This document describes the coding conventions and patterns used in the ExAlgo project to help maintain consistency across the codebase.

## Module Structure

### Naming and Organization
- Follow the pattern: `ExAlgo.<Category>.<ModuleName>` (e.g., `ExAlgo.Heap.LeftistHeap`)
- Categories: Heap, List, Queue, Stack, Sort, Search, Tree, Set, Number, Counting, Dynamic Programming
- One primary module per file
- Protocol implementations in `impls/` subdirectories

### Module Template
```elixir
defmodule ExAlgo.Category.ModuleName do
  @moduledoc """
  Brief description of what the module implements.

  Optional: Additional context, algorithm complexity, links to Wikipedia, etc.
  """

  # Aliases at the top
  alias __MODULE__

  # Nested modules for internal data structures
  defmodule Node do
    defstruct [:field1, :field2, field3: default_value]
  end

  # Main struct definition
  defstruct field1: [], field2: []

  # Type definitions
  @type t :: %__MODULE__{...}
  @type value_type :: any()

  # Public functions with @doc and @spec
  # Private functions
end
```

## Documentation

### Module Documentation
- Always include `@moduledoc` with clear, concise description
- Add algorithm complexity analysis when relevant
- Include links to external resources (Wikipedia, papers) for context
- Document performance characteristics and caveats

### Function Documentation
- Every public function must have `@doc`
- Always include `## Examples` section with IEx-style doctests
- Document edge cases
- Use special sections when needed:
  - `## Performance Note` - complexity warnings
  - `## Note on Complexity` - detailed analysis

Example:
```elixir
@doc """
Inserts an item into the queue.

## Examples

    iex> Queue.new() |> Queue.enqueue(1)
    %Queue{left: [1], right: []}

"""
```

## Type Specifications

- All public functions must have `@spec`
- Define custom types at module level with `@type`
- Common type patterns:
  ```elixir
  @type t :: %__MODULE__{...}
  @type value_type :: any()
  @type empty_error :: {:error, :empty_list}
  @type neg_index_error :: {:error, :negative_index}
  ```
- Use descriptive type names (`value_type()`, `item()`, etc.)
- Explicitly type error returns as union types

## Function Patterns

### Naming Conventions
- Use `snake_case` for all functions
- Prefix private helpers with `do_` (e.g., `do_merge`, `do_find`)
- Common function names:
  - `new/0`, `new/1` - constructors
  - `from/1` - create from enumerable
  - `insert/2`, `delete/2` - modifications
  - `find/2`, `find_min/1`, `find_max/1` - queries
  - `to_list/1`, `to_text/1`, `to_mermaid/1` - conversions

### Pattern Matching and Guards
- Use multiple function clauses for different cases
- Pattern match on struct fields in function heads
- Use guard clauses for validation:
```elixir
def find_min(%Empty{}), do: {:error, :empty}
def find_min(%Node{value: v}), do: {:ok, v}

def at(_, index) when index < 0, do: {:error, :negative_index}
```

### Error Handling
- Return tuples: `{:ok, value}` or `{:error, reason}`
- Use atoms for error reasons (`:empty`, `:underflow`, `:negative_index`)
- Use `with` statements for chaining operations that may fail

## Functional Programming Patterns

### Immutability
- Always return updated structures, never mutate
- Use struct update syntax:
```elixir
def enqueue(%__MODULE__{left: left} = queue, item),
  do: %{queue | left: [item | left]}
```

### Recursion
- Prefer tail-call optimization with accumulators
- Base cases first, recursive cases after
- Comment tail calls:
```elixir
defp do_merge(xs, ys, acc) do
  do_merge(xs, ys, [y | acc])  # Tail call!
end
```

### Pipe Operator
- Use `|>` extensively for data transformation
- Combine with `then/2` for intermediate steps:
```elixir
list
|> Enum.split(half)
|> then(fn {left, right} ->
  {merge_sort(left), merge_sort(right)}
end)
|> then(fn {left, right} -> do_merge(left, right, []) end)
```

## Protocol Implementations

### Organization
- Protocol implementations in separate files under `impls/` subdirectories
- Multiple related implementations can share a file
- Always alias the module at the top

### Common Protocols
Implement these protocols when appropriate:
- `Inspect` - custom inspect output
- `Enumerable` - for collection-like structures
- `Collectable` - for structures that can collect values

Example:
```elixir
defimpl Inspect, for: Queue do
  import Inspect.Algebra
  def inspect(queue, opts) do
    concat(["#ExAlgo.Queue<", to_doc(Queue.to_list(queue), opts), ">"])
  end
end
```

## Testing

### Test File Structure
```elixir
defmodule ExAlgo.Module.NameTest do
  use ExUnit.Case
  use ExUnitProperties  # When using property-based tests
  @moduletag :category_name

  alias ExAlgo.Module.Name

  doctest ExAlgo.Module.Name

  setup do
    {:ok, %{
      empty_struct: Name.new(),
      populated: Name.from(1..5)
    }}
  end

  describe "function_name/arity" do
    test "description", fixtures do
      # test implementation
    end

    property "property description" do
      check all data <- generator() do
        assert condition
      end
    end
  end
end
```

### Testing Conventions
- Always run doctests: `doctest ModuleName`
- Use `@moduletag` for categorization
- Group tests by function in `describe` blocks
- Use `setup` for test fixtures
- Property-based testing with StreamData for algorithms
- Test edge cases explicitly (empty, single element, negative values)
- Place helper functions at bottom of test file

## Code Formatting

- Use 2-space indentation
- Use `do:` for short single-line functions
- Multi-line for complex logic
- Comments use `#` with space after
- Format with `mix format`

## Architectural Patterns

### Nested Modules
Use nested modules for internal data structures:
```elixir
defmodule ExAlgo.Heap.LeftistHeap do
  alias __MODULE__

  defmodule Node do
    defstruct [:dist, :value, :left, :right]
  end

  defmodule Empty do
    defstruct []
  end
end
```

### Performance Documentation
- Include complexity notes in module docs
- Explain trade-offs in function documentation
- Comment optimizations (tail calls, etc.)

## Common Patterns in This Codebase

1. **Educational Focus**: Code emphasizes clarity and learning over micro-optimizations
2. **Comprehensive Documentation**: Every function has examples and doctests
3. **Strong Typing**: All public APIs are fully type-specified
4. **Functional Patterns**: Immutability, recursion, pattern matching throughout
5. **Test Coverage**: Both example-based and property-based tests
6. **Consistent Error Handling**: Tagged tuples for all error cases
