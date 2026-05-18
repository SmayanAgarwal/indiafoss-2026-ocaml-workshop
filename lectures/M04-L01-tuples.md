---
title: "Tuples"
lecture_no: 1
week: 4
duration_target_min: 22
concepts: [tuples, product types, pair, fst, snd, destructuring, tuple patterns]
keywords: [OCaml, tuple, pair, product type, destructuring]
activity_question: "Given [let p = (3, true, \"hi\")], what is the type of [p]? Write a function [first3 : 'a * 'b * 'c -> 'a] that returns the first component."
think_about_this: "Tuples in OCaml are *fixed-arity* — a [(int, int)] and a [(int, int, int)] are different types. Compare that to Python tuples, which are variable-arity. What does the OCaml choice buy you, and what does it cost?"
reading:
  - title: "Cornell CS3110, Tuples"
    url: https://cs3110.github.io/textbook/chapters/data/tuples.html
---

# Tuples

A tuple groups several values into one. The shape `(1, "hello")`
holds an `int` and a `string` together. Tuples are the simplest of
the *compound data types* OCaml provides; this lecture covers their
syntax, types, and how to take them apart.

:::slide

## A tuple is several values bundled

```ocaml
let pair    = (3, true)
let triple  = (1, "two", 3.0)
let nested  = ((1, 2), (3, 4))
```

`pair : int * bool`. `triple : int * string * float`. `nested :
(int * int) * (int * int)`.

The `*` in the type is "and": "an int *and* a bool". Note this is
the type-level `*`, not multiplication.

:::

The product-type notation `int * bool` is a syntactic crime that
trips up beginners, because in expression position `*` is
multiplication. The compiler always knows which is which from
context (a type position vs a value position), and you will get
used to reading `int * bool` as "pair of int and bool".

:::slide

## Tuples have a *fixed* size as part of their type

```ocaml
let _ : int * int       = (1, 2)
let _ : int * int * int = (1, 2, 3)
```

These are *different types*. You cannot pass an `int * int * int`
where an `int * int` is expected. Each tuple type is its own thing.

This contrasts with Python's tuples, which are variable-length: a
2-tuple and a 3-tuple are both just `tuple`. OCaml's choice gives
you static checking ("this function wants exactly two coordinates")
at the cost of needing a fresh type for each shape.

:::

:::slide

## Constructing and extracting

```ocaml
let p = (10, 20)
let _ = fst p
let _ = snd p
```

`fst : 'a * 'b -> 'a`, `snd : 'a * 'b -> 'b`. They work on pairs
only. For triples (or larger) you destructure:

```ocaml
let (x, y, z) = (1, 2, 3)
let _ = x
let _ = y
let _ = z
```

The `let (x, y, z) = ...` is a **pattern**: it gives names to each
component at once.

:::

This is the first time we've used `let` with anything more
structured than a single name. The thing after `let` is a pattern.
For tuples, the pattern is `(x, y)` or `(x, y, z)` etc., and OCaml
matches the right-hand side against it, binding each name.

If the pattern doesn't fit (wrong arity), it's a *type* error, not
a runtime crash. The compiler catches it.

:::slide

## Pattern matching in function arguments

```ocaml
let distance (x1, y1) (x2, y2) =
  let dx = x2 -. x1 in
  let dy = y2 -. y1 in
  sqrt (dx *. dx +. dy *. dy)

let _ = distance (0.0, 0.0) (3.0, 4.0)
```

`float = 5.0`. The function takes two pairs; each parameter is a
*pattern* `(x1, y1)`. OCaml binds `x1` and `y1` from the first
argument, `x2` and `y2` from the second.

The inferred type is `float * float -> float * float -> float`.
Two pairs in, one float out.

:::

:::slide

## Tuples are for *heterogeneous* data, *known shape*

Use a tuple when:

- You have a small, fixed number of values to bundle (2, 3, 4).
- The values may have different types.
- The shape is *obvious from context*: a point is a pair `(x, y)`,
  a key-value entry is a pair `(key, value)`.

Don't use a tuple when:

- You'd want to access fields by *name* (use a record; next lecture).
- You'd have ten fields (use a record).
- The number of values varies (use a list).

Tuples are great when there are two or three of something and the
positions speak for themselves.

:::

:::slide

## Returning multiple values

OCaml functions return a single value, but that value can be a
tuple:

```ocaml
let divmod a b =
  (a / b, a mod b)

let _ = divmod 17 5
```

`(int * int) = (3, 2)`. The function returns a pair. Callers
destructure:

```ocaml
let (q, r) = divmod 17 5
```

This is the OCaml idiom for what Python or Go do with multiple
return values.

:::

:::slide

## Tuples in collections

You'll often see lists of tuples (each tuple a "row"):

```ocaml
let pairs = [(1, "one"); (2, "two"); (3, "three")]
```

`(int * string) list`. A list whose elements are pairs of `int`
and `string`.

To search this for a key:

```ocaml
let rec lookup key = function
  | [] -> None
  | (k, v) :: rest ->
      if k = key then Some v else lookup key rest

let _ = lookup 2 pairs
```

`string option = Some "two"`. The pattern `(k, v) :: rest`
destructures the head of the list (a pair) and binds `k` and `v`
at once.

We will see `option` in lecture 5 of this module, and more on lists
in Module 5. Treat this as a preview.

:::

:::slide

## Tuples as keys / values in higher-order code

```ocaml
let nums = [1; 2; 3; 4; 5]
let _ = List.map (fun x -> (x, x * x)) nums
```

`(int * int) list = [(1,1); (2,4); (3,9); (4,16); (5,25)]`.
Each input maps to a pair of (input, square).

This pattern (map a list into pairs) is how you'd build a small
table from a computation.

:::

:::slide

## Activity

Given `let p = (3, true, "hi")`, predict:

1. The type of `p`.
2. A function `first3 : 'a * 'b * 'c -> 'a` returning the first
   component.

Write the function.

:::

:::slide

## Activity discussion

1. `p : int * bool * string`. Three components, in order.
2. Function:

```ocaml
let first3 (x, _, _) = x
```

`val first3 : 'a * 'b * 'c -> 'a = <fun>`.

The `_` in the pattern is "ignore this component". We only care
about the first.

Try `first3 p`:

```ocaml
let _ = first3 (3, true, "hi")
```

`int = 3`.

:::

:::slide

## What's next

Lecture 2: **records**. Same idea as tuples but with *named*
fields. When your bundle has more than three things, records are
clearer.

:::

## Reading

- **Cornell CS3110**, *Tuples*:
  <https://cs3110.github.io/textbook/chapters/data/tuples.html>
