---
title: "Tutorial: rebuild parts of `List`"
lecture_no: 6
week: 6
duration_target_min: 28
concepts: [worked higher-order, reimplement standard library, fold-everywhere, composition]
keywords: [OCaml, List, tutorial, higher-order, rebuild]
activity_question: "Write [maximum : 'a list -> 'a option] that returns the largest element of a list, or [None] if empty. Express it using [List.fold_left]."
think_about_this: "Almost every concrete list function can be written in terms of [fold_left] or [fold_right]. Why aren't they written that way in the standard library? What would you lose if they were?"
reading:
  - title: "Cornell CS3110, Re-implementing the List module"
    url: https://cs3110.github.io/textbook/chapters/hop/index.html
---

# Tutorial for Module 6

We rebuild several functions from `List` using only `map`, `filter`,
`fold_left`, `fold_right`, and the basic list constructors. The goal
is to internalize how versatile a small higher-order toolkit is.

:::slide

## Problem 1: `length`

```ocaml
let length xs = List.fold_left (fun n _ -> n + 1) 0 xs

let _ = length [10; 20; 30; 40]
```

`int = 4`.

- Ignore the element; bump the counter.
- Tail-recursive, constant stack.

:::

:::slide

## Problem 2: `sum`

```ocaml
let sum xs = List.fold_left (+) 0 xs

let _ = sum [1; 2; 3; 4; 5]
```

`int = 15`.

- `+` is the combining function.
- `0` is the starting accumulator.

Same shape for `product`:

```ocaml
let product xs = List.fold_left ( * ) 1 xs

let _ = product [1; 2; 3; 4; 5]
```

`int = 120`.

- Accumulator starts at `1` (identity for multiplication).

:::

:::slide

## Problem 3: `rev`

```ocaml
let rev xs = List.fold_left (fun acc x -> x :: acc) [] xs

let _ = rev [1; 2; 3; 4]
```

`[4; 3; 2; 1]`.

- Prepend each element to the accumulator.
- Left-to-right traversal + prepending: first element ends up *deepest*.
- Result is reversed.

:::

:::slide

## Problem 4: `map` (via fold_right)

```ocaml
let map f xs =
  List.fold_right (fun x acc -> f x :: acc) xs []

let _ = map (fun n -> n * n) [1; 2; 3; 4]
```

`[1; 4; 9; 16]`.

- `fold_right` walks right-to-left.
- Cons-order matches the original order.
- Combining function: take `x`, apply `f`, cons onto the running list.

Same with `fold_left + rev`:

```ocaml
let map_tail f xs =
  List.rev (List.fold_left (fun acc x -> f x :: acc) [] xs)

let _ = map_tail (fun n -> n * n) [1; 2; 3; 4]
```

Two passes, but tail-recursive.

:::

:::slide

## Problem 5: `filter` (via fold_right)

```ocaml
let filter p xs =
  List.fold_right
    (fun x acc -> if p x then x :: acc else acc)
    xs []

let _ = filter (fun n -> n mod 2 = 0) [1; 2; 3; 4; 5; 6]
```

`[2; 4; 6]`.

- For each element, decide whether to include it.
- Combining function picks either `x :: acc` or `acc`.

:::

:::slide

## Problem 6: `concat`

Flatten a list of lists into a single list.

```ocaml
let concat xss =
  List.fold_right (fun xs acc -> xs @ acc) xss []

let _ = concat [[1; 2]; [3; 4; 5]; [6]]
```

`[1; 2; 3; 4; 5; 6]`.

- `@` is list-append.
- Fold over the outer list; append each inner list to the accumulator.
- `O(n)` in total length, but builds up garbage from intermediate appends.
- For very long inputs, `List.concat` from the standard library is
  more efficient.

:::

:::slide

## Problem 7: `for_all` and `exists`

```ocaml
let for_all p xs = List.fold_left (fun acc x -> acc && p x) true xs

let exists p xs = List.fold_left (fun acc x -> acc || p x) false xs

let _ = for_all (fun n -> n > 0) [1; 2; 3]
let _ = for_all (fun n -> n > 0) [1; -2; 3]
let _ = exists (fun n -> n < 0) [1; -2; 3]
```

`true`, `false`, `true`.

- `for_all`: accumulator starts `true`; an element with `p x = false`
  drags the whole `&&` to false.
- `exists`: accumulator starts `false`; a passing element flips the
  `||` to true.
- These don't short-circuit: fold visits every element.
- The standard library's `List.for_all` / `List.exists` do
  short-circuit; prefer those for long lists with early failure.

:::

:::slide

## Problem 8: `count`

How many elements satisfy a predicate?

```ocaml
let count p xs =
  List.fold_left (fun n x -> if p x then n + 1 else n) 0 xs

let _ = count (fun n -> n > 0) [-1; 5; -3; 8; 0; 2]
```

`int = 3`.

- Three positive elements.
- Accumulator counts; combining function bumps on a passing element.
- Alternative: `List.length (List.filter p xs)`.
- Fold version is one pass, no intermediate list.

:::

:::slide

## Activity

Write `maximum : 'a list -> 'a option` returning the largest
element of a list, or `None` if empty. Use `List.fold_left`.

:::

:::slide

## Activity solution

```ocaml
let maximum xs =
  List.fold_left
    (fun acc x ->
      match acc with
      | None -> Some x
      | Some m -> Some (max m x))
    None xs

let _ = maximum [3; 7; 1; 9; 5]
let _ = maximum ([] : int list)
```

`Some 9`, `None`.

- Accumulator is an `int option`.
- Starts at `None` (no element seen yet).
- For each element: if `None`, take this element; otherwise keep the larger.
- `([] : int list)` annotation is needed: `[]` alone is polymorphic
  and OCaml needs to pick a type.

:::

:::slide

## What you should be able to do now

After Module 6 you can:

- Write functions that take or return other functions.
- Use `List.map` to transform every element of a list.
- Use `List.filter` to keep elements that pass a predicate.
- Use `List.fold_left` / `List.fold_right` to reduce a list to any
  value.
- Chain operations with `|>` pipelines.
- Recognize when the standard library has a function for the job.

What's coming up:

- Module 7: side effects (`ref`, mutation, exceptions) and **modules**
  (the OCaml language feature, not the NPTEL kind).
- Module 8: monads and GADTs.

:::

## Reading

- **Cornell CS3110**, *Re-implementing the List module*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
