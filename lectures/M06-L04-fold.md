---
title: "`fold`: reduce a list to a single value"
lecture_no: 4
week: 6
duration_target_min: 25
concepts: [fold, fold_left, fold_right, reduction, accumulator, generalization]
keywords: [OCaml, fold, fold_left, fold_right, reduce, accumulator]
activity_question: "Express [List.length xs] using [List.fold_left]. Express [List.rev xs] using [List.fold_left]. Why does [List.fold_left (fun a x -> x :: a) [] xs] produce the reverse and not the original?"
think_about_this: "[fold_left] is tail-recursive and goes left-to-right; [fold_right] is not tail-recursive and goes right-to-left. When is each one the natural fit?"
reading:
  - title: "Cornell CS3110, fold"
    url: https://cs3110.github.io/textbook/chapters/hop/index.html
---

# `fold`: reduce a list to a single value

`fold` is the most general of the three canonical list higher-order
functions. Where `map` returns a list and `filter` returns a list,
`fold` returns *anything you want*: a number, a string, another
list, a record. Anything that's computed by walking the elements
and accumulating.

:::slide

## The shape

```ocaml
let rec fold_left f acc = function
  | [] -> acc
  | x :: rest -> fold_left f (f acc x) rest

let _ = fold_left (+) 0 [1; 2; 3; 4]
```

`int = 10`.

- Sum of the list: fold `+` over it with starting accumulator `0`.
- Type: `('acc -> 'a -> 'acc) -> 'acc -> 'a list -> 'acc`.
- The function combines running accumulator with each element to
  produce the next accumulator.

:::

:::slide

## What `fold_left` does, step by step

`fold_left f acc [x1; x2; x3]` evaluates to:

```
f (f (f acc x1) x2) x3
```

- `f` applied first to `acc` and `x1`.
- Then to that result and `x2`.
- Then to that result and `x3`.
- Each intermediate result becomes the new accumulator.

For `fold_left (+) 0 [1; 2; 3]`:

```
((0 + 1) + 2) + 3
= (1 + 2) + 3
= 3 + 3
= 6
```

:::

:::slide

## `fold_left` is tail-recursive

- The recursive call has nothing after it.
- OCaml optimizes it to a loop.
- Constant stack space, regardless of list length.
- Right choice when order doesn't matter, or the accumulator
  naturally fits left-to-right folding.

:::

:::slide

## `fold_right`: the other direction

`fold_right f xs acc` evaluates to:

```
f x1 (f x2 (f x3 acc))
```

- Right-associative.
- The function takes the **element first**, accumulator second.

```ocaml
let _ = List.fold_right (fun x acc -> x :: acc) [1; 2; 3] []
```

`[1; 2; 3]`.

- With `::` as `f`, this rebuilds the list exactly.
- Useful for "preserve order" computations.

:::

:::slide

## `fold_right` is *not* tail-recursive

```ocaml
let rec fold_right f xs acc =
  match xs with
  | [] -> acc
  | x :: rest -> f x (fold_right f rest acc)
```

- `f x (...)` does work *after* the recursive call.
- Not tail-recursive: stack-overflow risk on long lists.
- For very long lists, prefer `fold_left` with an accumulator tweak.
- Or use `List.rev (fold_left ...)` for right-to-left semantics.

:::

:::slide

## `map` in terms of `fold`

`map` is `fold_right` with the right combining function:

```ocaml
let map_via_fold f xs =
  List.fold_right (fun x acc -> f x :: acc) xs []

let _ = map_via_fold (fun n -> n * n) [1; 2; 3]
```

`[1; 4; 9]`.

- Accumulator starts as `[]`.
- For each element (right-to-left) we cons `f x` onto it.

Or with `fold_left` and a reverse:

```ocaml
let map_via_fold_left f xs =
  List.rev (List.fold_left (fun acc x -> f x :: acc) [] xs)

let _ = map_via_fold_left (fun n -> n * n) [1; 2; 3]
```

Same result. Two passes (fold then rev), but tail-recursive.

:::

:::slide

## `filter` in terms of `fold`

```ocaml
let filter_via_fold p xs =
  List.fold_right
    (fun x acc -> if p x then x :: acc else acc)
    xs []

let _ = filter_via_fold (fun n -> n > 2) [1; 2; 3; 4]
```

`[3; 4]`.

- The combining function decides whether to include each element.
- `fold` is more general than `map` or `filter`.
- Both can be expressed in terms of it.

:::

:::slide

## Beyond lists: fold any structure

The fold idea generalizes to any recursive type. For trees:

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec fold_tree f acc = function
  | Leaf -> acc
  | Node (l, v, r) ->
      let acc = fold_tree f acc l in
      let acc = f acc v in
      fold_tree f acc r

let _ = fold_tree (+) 0
          (Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Leaf)))
```

`int = 6`.

- An in-order tree fold.
- Accumulator visits left subtree, then root, then right subtree.
- Once internalized, fold applies to any shape: trees, expressions,
  records-of-lists.

:::

:::slide

## When `fold` is overkill

- Prefer `map` or `filter` when you can: they read better and
  signal intent more clearly.
- Reach for `fold` when the answer isn't a list (a number, a
  record, a `Map`).
- Or when you need both summary and transformation in one pass.

```ocaml
(* Both produce the same answer; prefer the first *)
let sum_squares_a xs = xs |> List.map (fun x -> x * x) |> List.fold_left (+) 0
let sum_squares_b xs = List.fold_left (fun acc x -> acc + x * x) 0 xs

let _ = sum_squares_a [1; 2; 3]
let _ = sum_squares_b [1; 2; 3]
```

Both give `14`.

- First: pipeline (map, then sum).
- Second: one fold.
- First is clearer for small steps; second is more efficient (one pass).

:::

:::slide

## Activity

Express `List.length xs` and `List.rev xs` using only
`List.fold_left`.

:::

:::slide

## Activity solution

```ocaml
let length xs = List.fold_left (fun n _ -> n + 1) 0 xs

let rev xs = List.fold_left (fun acc x -> x :: acc) [] xs

let _ = length [10; 20; 30; 40]
let _ = rev [1; 2; 3; 4]
```

`4`, `[4; 3; 2; 1]`.

- `length`: ignore each element, bump the counter.
- `rev`: prepend each element to the accumulator.
- Prepending left-to-right puts the first element *deepest*: reversed.
- Try `List.fold_right (fun x acc -> x :: acc) xs []`: you get the
  *original* order, because `fold_right` walks right-to-left.

:::

:::slide

## What's next

Lecture 5: **function composition and pipelines**.

- The plumbing that strings `map`, `filter`, `fold` together cleanly.
- Then the Module 6 tutorial.

:::

## Reading

- **Cornell CS3110**, *fold*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
