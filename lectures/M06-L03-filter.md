---
title: "`filter`: keep what passes the predicate"
lecture_no: 3
week: 6
duration_target_min: 20
concepts: [filter, predicate, list filtering, filter_map, partition]
keywords: [OCaml, filter, predicate, list, higher-order]
activity_question: "Write [unique : 'a list -> 'a list] that removes duplicate elements. (Hint: combine [filter] with a notion of 'haven't seen this yet'.)"
think_about_this: "[filter] returns a sublist of its input. [map] returns a list of the same length. What kind of operation would return a list of *different* length but not necessarily a sublist? Where would you reach for [filter_map]?"
reading:
  - title: "Cornell CS3110, filter"
    url: https://cs3110.github.io/textbook/chapters/hop/index.html
---

# `filter`: keep what passes the predicate

`filter` takes a predicate `p` and a list `xs`, and returns the
elements of `xs` for which `p x` is `true`. It is the second
canonical higher-order list operation.

:::slide

## Definition

```ocaml
let rec filter p = function
  | [] -> []
  | x :: rest ->
      if p x then x :: filter p rest
      else filter p rest

let _ = filter (fun x -> x mod 2 = 0) [1; 2; 3; 4; 5; 6]
```

`int list = [2; 4; 6]`.

- Type: `('a -> bool) -> 'a list -> 'a list`.
- Predicate takes an element and returns a `bool`.
- Result list has the **same element type**, possibly shorter.

:::

:::slide

## `filter` in the standard library

```ocaml
let _ = List.filter (fun n -> n > 5) [3; 7; 1; 8; 2; 9]
let _ = List.filter (fun s -> String.length s > 3) ["hi"; "hello"; "ok"; "world"]
```

`[7; 8; 9]`, `["hello"; "world"]`.

- Same pattern: predicate first, list second.
- Result is a sublist: elements in the same order, just fewer.

:::

:::slide

## Combining `map` and `filter`

```ocaml
let big_squares xs =
  xs
  |> List.map (fun x -> x * x)
  |> List.filter (fun y -> y > 10)

let _ = big_squares [1; 2; 3; 4; 5]
```

`[16; 25]`.

- `|>` is the *pipeline operator*: `x |> f` is the same as `f x`.
- Lets you read left-to-right (covered fully in Lecture 5).
- Top-to-bottom: start with the list, square each, keep those above 10.

:::

:::slide

## `filter` doesn't change order

- Like `map`, `filter` preserves relative order.
- The output is a subsequence of the input.

```ocaml
let _ = List.filter (fun x -> x > 3) [5; 1; 7; 2; 9; 3; 4]
```

`[5; 7; 9; 4]`.

- Elements that passed, in the order they appeared.
- Matters when filtering a sorted list or a log of timestamped events.
- Order is preserved for you.

:::

:::slide

## `filter_map`: filter and transform together

Sometimes you want to keep *and* transform in one pass:

```ocaml
let parse_ints xs =
  List.filter_map int_of_string_opt xs

let _ = parse_ints ["42"; "frog"; "13"; "; "; "0"]
```

`[42; 13; 0]`.

- `int_of_string_opt : string -> int option`.
- `Some n` if it parses, `None` otherwise.
- `filter_map` discards `None`s and unwraps `Some`s.
- Equivalent to `filter Option.is_some |> map Option.get`, but in
  one pass and with no exception risk.

:::

`filter_map` is one of those "where was this all my life" functions
once you discover it. Any pipeline of "parse, drop the failures,
move on" benefits from it.

:::slide

## `partition`: keep both halves

```ocaml
let (passed, failed) =
  List.partition (fun n -> n >= 60) [85; 42; 73; 30; 95; 58]

let _ = passed
let _ = failed
```

`[85; 73; 95]`, `[42; 30; 58]`.

- `partition p xs` returns *two* lists: passed, then failed.
- Equivalent to `filter p` and `filter (not p)`.
- But done in a single pass.

:::

:::slide

## A real-world filter pipeline

```ocaml
type book = { title : string; year : int; pages : int }

let library = [
  { title = "OCaml";   year = 2020; pages = 350 };
  { title = "Rust";    year = 2024; pages = 600 };
  { title = "Old";     year = 1985; pages = 200 };
  { title = "Recent";  year = 2023; pages = 50 };
]

let modern_long = List.filter
  (fun b -> b.year >= 2020 && b.pages > 100)
  library

let _ = List.map (fun b -> b.title) modern_long
```

`["OCaml"; "Rust"]`.

- Filter on a compound predicate (modern *and* long).
- Then map to titles.
- This filter-then-map pattern is sometimes called *select-where* or
  *project-select*. In OCaml: two chained function calls.

:::

:::slide

## Activity

Write `unique : 'a list -> 'a list` that removes duplicate
elements, keeping the first occurrence of each.

Hint: use the helper function `List.mem : 'a -> 'a list -> bool`
which checks if an element is in a list.

:::

:::slide

## Activity solution

```ocaml
let unique xs =
  let rec go seen = function
    | [] -> List.rev seen
    | x :: rest ->
        if List.mem x seen then go seen rest
        else go (x :: seen) rest
  in
  go [] xs

let _ = unique [1; 2; 1; 3; 2; 4; 1]
let _ = unique ["a"; "b"; "a"; "c"; "b"]
```

`[1; 2; 3; 4]`, `["a"; "b"; "c"]`.

- Maintain a `seen` list (in reverse for efficiency).
- Include each element only if not already seen.
- `List.mem` is `O(n)` per call: overall `O(n²)`.
- Fine for short lists; use a `Set` (Module 7) for big lists.

:::

:::slide

## What's next

Lecture 4: **`fold`**.

- The most general of the three.
- Both `map` and `filter` can be expressed in terms of `fold`.
- Once you grok `fold`, most list computations follow.

:::

## Reading

- **Cornell CS3110**, *filter*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
