---
title: "Variants (sum types)"
lecture_no: 3
week: 4
duration_target_min: 24
concepts: [variants, sum types, constructors, payloads, pattern matching]
keywords: [OCaml, variant, sum type, constructor, ADT, algebraic data type]
activity_question: "Define a variant type [shape] with three constructors: [Circle of float], [Square of float], [Rectangle of float * float]. Write [area : shape -> float] that returns each shape's area."
think_about_this: "If you wanted to add a [Triangle] case to the [shape] type, what files in a real codebase would you have to touch? What does the compiler do for you, and what does it not?"
reading:
  - title: "Cornell CS3110, Variants"
    url: https://cs3110.github.io/textbook/chapters/data/variants.html
---

# Variants (sum types)

A *variant* type expresses "*this or that*". A `shape` is a `Circle`
*or* a `Square` *or* a `Rectangle`. A `result` is a `Success` *or*
a `Failure`. Records are products (this *and* that); variants are
sums (this *or* that). Together they're the algebra in **algebraic
data types**, and they're the single most distinctive thing about
modeling data in OCaml.

If you've worked in C, the closest analogue is `enum` plus a
tagged `union` plus the discipline to keep them in sync. OCaml
bundles all three into one declaration and makes the compiler
enforce that you handle every case.

:::slide

## Declaring a variant

```ocaml
type direction = North | South | East | West

let d = North
```

Four *constructors*, separated by `|`. Each is a distinct value
of type `direction`. `North`, `South`, etc. are written
capitalized (constructors always start with a capital).

A variable of type `direction` holds *exactly one* of these four.

This is what an `enum` looks like in C or Java.

:::

:::slide

## Constructors with payload

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let c = Circle 3.0
let s = Square 5.0
let r = Rectangle (4.0, 6.0)
```

Three constructors, each carrying data: a `Circle` carries one
`float` (its radius), a `Square` one `float` (side length), a
`Rectangle` two `float`s (width and height).

`Circle 3.0` is a value. `Square 5.0` is another value. They both
have type `shape`. The constructor tells you *which kind* of shape,
and the payload gives the data for that kind.

:::

:::slide

## Pattern matching on variants

```ocaml
let area s =
  match s with
  | Circle r -> 3.14159 *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h

let _ = area (Circle 3.0)
let _ = area (Rectangle (4.0, 6.0))
```

`28.27...` and `24.0`. The `match` expression inspects which
constructor was used and binds the payload to local names. For
`Circle r`, the `r` is the float we packed in.

This is what a `switch` looks like in C, but with two crucial
upgrades: the compiler checks that you handled every constructor,
and you can destructure the payload at the same time.

:::

The combination of variants + pattern matching is the engine of
nearly every interesting program written in OCaml. You will see it
in interpreters, parsers, type checkers, network protocol decoders,
compilers, configuration loaders. Whenever data has multiple
*kinds*, a variant is the OCaml way to say so.

:::slide

## Exhaustiveness checking

What if we forget a case?

```ocaml
let area s =
  match s with
  | Circle r -> 3.14159 *. r *. r
  | Square s -> s *. s
```

OCaml warns:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Rectangle (_, _)
```

The compiler tells you that `Rectangle` is unhandled. It even tells
you what shape of case it expects. This warning *catches a class
of bugs* statically, before any test runs.

In stricter projects you turn this warning into an error: forgetting
a case becomes a compile failure. We'll see how to enable that in
Module 7 when we discuss dune configuration.

:::

:::slide

## Adding a case

Now suppose we want to add `Triangle`:

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float
  | Triangle of float * float * float

let area s =
  match s with
  | Circle r -> 3.14159 *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h
```

Suddenly the compiler warns *every* `match` on `shape` that doesn't
handle `Triangle`. We get a punch list of places to update.

This is "refactor with the compiler's help": add a case, compile,
fix every site the compiler flags. When the warnings stop, the
refactor is done.

:::

:::slide

## The recipe for a finite "this or that"

Whenever you have data that can take one of several distinct
shapes, the OCaml recipe is:

1. Declare a variant with one constructor per shape.
2. Attach payload data to each constructor as needed.
3. Use `match` to inspect and act on values of that type.

```ocaml
type tcp_state =
  | Listening
  | Connecting of { peer : string }
  | Connected of { peer : string; bytes_sent : int }
  | Closed of { reason : string }
```

A connection is in one of four states; each state carries the data
relevant to *that* state. `Listening` carries no payload (it's
just a tag); the others carry what they need.

(That syntax with `{ ... }` is a variant constructor whose payload is
a small inline record. Convenient when the payload itself is
multi-field.)

:::

:::slide

## Built-in variants you've already used

The `bool` type is a variant:

```
type bool = true | false
```

(Sort of. The constructors are lowercase by special dispensation.)

The `list` type is a variant:

```
type 'a list = [] | (::) of 'a * 'a list
```

`[]` is the empty-list constructor; `::` is the cons constructor
with two payloads: head and tail. List patterns like `x :: rest`
are just *variant pattern matching* on this declaration.

`option` is a variant:

```
type 'a option = None | Some of 'a
```

`None` is the "no value" constructor; `Some x` wraps a value.

Every time you've matched on a list, you've been using variant
pattern matching.

:::

:::slide

## Variants with generic payloads

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let t : int tree =
  Node (
    Node (Leaf, 1, Leaf),
    2,
    Node (Leaf, 3, Node (Leaf, 4, Leaf)))
```

A binary tree carrying values of any type `'a`. `Leaf` is empty;
`Node (l, v, r)` has a left subtree, a value, and a right subtree.

We will work with this in Module 4 lecture 4 (recursive types) and
Module 5 (pattern matching).

:::

:::slide

## Activity

Define `shape` with three constructors: `Circle of float`,
`Square of float`, `Rectangle of float * float`. Write `area :
shape -> float` returning the area for each case.

:::

:::slide

## Activity solution

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let area = function
  | Circle r -> 3.14159 *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h

let _ = area (Circle 2.0)
let _ = area (Square 3.0)
let _ = area (Rectangle (4.0, 5.0))
```

`12.56...`, `9.0`, `20.0`.

(`function` is shorthand for `fun x -> match x with ...`. Common
when a function's whole body is a `match` on its argument.)

:::

:::slide

## What's next

Lecture 4: **recursive types**. Variants whose payloads include the
type being defined. Lists and trees both fit this shape, and so do
arithmetic expressions, JSON values, and more. The recursive case
is what makes algebraic data types *powerful*, not just *labelled*.

:::

## Reading

- **Cornell CS3110**, *Variants*:
  <https://cs3110.github.io/textbook/chapters/data/variants.html>
