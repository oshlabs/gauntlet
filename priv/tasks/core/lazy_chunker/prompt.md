Write a module `LazyChunker` with a function `by_budget/2` that lazily chunks an enumerable of non-negative integers into consecutive chunks whose sums stay within a budget.

`by_budget(enum, budget)` returns a `Stream` (or any lazy enumerable) of lists such that:

- Elements appear in their original order, each in exactly one chunk.
- A chunk is closed before adding an element that would push its sum above `budget`; that element starts the next chunk.
- An element larger than `budget` forms a chunk on its own.
- No empty chunks are emitted.
- **The implementation must be lazy**: it will be called with an infinite stream as input, and taking the first few chunks must terminate.

Examples:

    LazyChunker.by_budget([1, 2, 3, 4, 5], 5) |> Enum.to_list()
    #=> [[1, 2], [3], [4], [5]]

    LazyChunker.by_budget([9, 1, 1], 5) |> Enum.to_list()
    #=> [[9], [1, 1]]

    Stream.cycle([2]) |> LazyChunker.by_budget(6) |> Enum.take(2)
    #=> [[2, 2, 2], [2, 2, 2]]
