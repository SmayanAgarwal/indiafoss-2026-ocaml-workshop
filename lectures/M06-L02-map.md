---
title: "`map`: transform every element"
lecture_no: 2
week: 6
duration_target_min: 22
concepts: [map, transformation, list traversal, polymorphism, function arguments]
keywords: [OCaml, map, list, higher-order, transformation]
activity_question: "Write [zip_with : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list] that pairs up two lists element-wise using the given combining function. What happens for lists of different lengths?"
think_about_this: "Why is [List.map] not tail-recursive in the standard library? What problem would a naive tail-recursive version run into?"
reading:
  - title: "Cornell CS3110, map"
    url: https://cs3110.github.io/textbook/chapters/hop/index.html
---

# `map`: transform every element

`map` takes a function `f` and a list `xs`, and produces a new list
where every element is `f` applied to the corresponding element of
`xs`. It is the workhorse of list-flavoured OCaml.

:::slide

## Definition

```ocaml
let rec map f = function
  | [] -> []
  | x :: rest -> f x :: map f rest

let _ = map (fun x -> x * x) [1; 2; 3; 4]
```

`int list = [1; 4; 9; 16]`.

- `f : 'a -> 'b`.
- Input is `'a list`, output is `'b list`.
- Same length; possibly different element types.

:::

:::slide

## Type and what it tells you

```ocaml
let rec map (f : 'a -> 'b) (xs : 'a list) : 'b list =
  match xs with
  | [] -> []
  | x :: rest -> f x :: map f rest
```

`('a -> 'b) -> 'a list -> 'b list`.

What the signature says:

- Takes a function from some type `'a` to some type `'b`.
- Takes a list of `'a`.
- Returns a list of `'b`.
- The two element types may differ (e.g. `int list -> string list`).
- Always *one-to-one*: no element dropped or duplicated.

:::

:::slide

## `map` in the standard library

The library version is `List.map`:

```ocaml
let _ = List.map (fun x -> x * 2) [1; 2; 3]
let _ = List.map string_of_int [1; 2; 3]
let _ = List.map String.length ["hello"; "world"; "!"]
```

`[2; 4; 6]`, `["1"; "2"; "3"]`, `[5; 5; 1]`.

Each call transforms the list element-by-element with the given function.

:::

:::slide

## Partial application + map

```ocaml
let _ = List.map ((+) 10) [1; 2; 3]
let _ = List.map (( * ) 2) [1; 2; 3]
```

`[11; 12; 13]` and `[2; 4; 6]`.

- `(+) 10` is the function "add 10".
- `( * ) 2` is "multiply by 2".
- Both are partial applications of infix operators; no lambdas needed.
- You'll write `List.map ((+) k)` more often than
  `List.map (fun x -> x + k)`: less noise, intent is clear.

:::

:::slide

## `map` doesn't change the length

- `List.map f xs` has the **same length** as `xs`. Always.
- One input element produces exactly one output element.

When you want something else:

- Drop elements: `List.filter` (Lecture 3).
- Drop *and* transform: `List.filter_map`.
- Totally different shape: `List.fold_left` (Lecture 4).

`map` is for "transform each element in place".

:::

:::slide

## Tail recursion and `List.map`

The naive definition we wrote is *not* tail-recursive:

```ocaml
let rec map f = function
  | [] -> []
  | x :: rest -> f x :: map f rest
```

- `f x :: map f rest` does work *after* the recursive call (the cons).
- Very long lists overflow the stack.
- `List.map` handles "reasonable" lengths gracefully.
- For very long inputs, prefer `List.rev (List.rev_map f xs)`.

A tail-recursive version with an accumulator:

```ocaml
let map f xs =
  let rec go acc = function
    | [] -> List.rev acc
    | x :: rest -> go (f x :: acc) rest
  in
  go [] xs

let _ = map (fun x -> x * x) [1; 2; 3; 4]
```

`[1; 4; 9; 16]`.

- Accumulate in reverse, then reverse at the end.
- Two passes through the list, constant stack.

:::

:::slide

## `map` on options and trees

- `map` is a *pattern*, not just a list function.
- The idea generalises to anything that "contains" elements:

```ocaml
let _ = Option.map (fun x -> x + 1) (Some 5)
let _ = Option.map (fun x -> x + 1) None
```

`Some 6`, `None`.

- `Option.map` applies the function inside `Some`.
- It passes `None` through unchanged.

For trees:

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec map_tree f = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (map_tree f l, f v, map_tree f r)

let _ = map_tree (fun x -> x * 10)
                 (Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Leaf)))
```

`Node (Node (Leaf, 10, Leaf), 20, Node (Leaf, 30, Leaf))`.

- Same shape; every value multiplied by 10.
- Any "container of elements" type can have its own `map`.

:::

:::slide

## Activity

Write `zip_with : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list`
that pairs up two lists element-wise using the given function. Stop
when the shorter list runs out.

:::

:::slide

## Activity solution

```ocaml
let rec zip_with f xs ys =
  match xs, ys with
  | [], _ | _, [] -> []
  | x :: xr, y :: yr -> f x y :: zip_with f xr yr

let _ = zip_with (+) [1; 2; 3] [10; 20; 30]
let _ = zip_with (fun a b -> a ^ b) ["he"; "wo"] ["llo"; "rld"]
let _ = zip_with (+) [1; 2; 3] [10; 20]
```

`[11; 22; 33]`, `["hello"; "world"]`, `[11; 22]`.

- `[], _ | _, []` is an or-pattern catching either list empty.
- When either runs out, we stop.
- Third call: extra element of the longer list is dropped.

:::

:::slide

## What's next

Lecture 3: **`filter`**.

- Keep only the elements that match a predicate.
- The second of the three canonical higher-order list operations
  (`map`, `filter`, `fold`).

:::

## Reading

- **Cornell CS3110**, *map*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
