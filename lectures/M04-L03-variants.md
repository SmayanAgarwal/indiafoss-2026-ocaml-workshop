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

- Four *constructors*, separated by `|`
- Each is a distinct value of type `direction`
- Constructors are **capitalized** (always start with a capital)
- A `direction` value holds *exactly one* of the four
- This is what an `enum` looks like in C or Java

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

Three constructors, each carrying data:

- `Circle` carries one `float` (radius)
- `Square` carries one `float` (side length)
- `Rectangle` carries two `float`s (width, height)

- `Circle 3.0`, `Square 5.0`: both values of type `shape`
- Constructor: *which kind* of shape
- Payload: data for that kind

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

- Results: `28.27...` and `24.0`
- `match` inspects which constructor was used
- Binds the payload to local names (`Circle r`: `r` is the packed float)
- Like a `switch` in C, with two upgrades:
  - Compiler checks **every** constructor is handled
  - You can **destructure** the payload at the same time

:::

The combination of variants + pattern matching is the engine of
nearly every interesting program written in OCaml. You will see it
in interpreters, parsers, type checkers, network protocol decoders,
compilers, configuration loaders. Whenever data has multiple
*kinds*, a variant is the OCaml way to say so.

:::slide

## Exhaustiveness checking

What if we forget a case?

```ocaml skip
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

- Compiler flags that `Rectangle` is unhandled
- Even tells you the *shape* of the missing case
- Catches a class of bugs **statically**, before any test runs
- Stricter projects turn this warning into an **error**
- Forgetting a case becomes a compile failure
- (Module 7 will show how to enable that via dune)

:::

:::slide

## Adding a case

Now suppose we want to add `Triangle`:

```ocaml skip
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

- Compiler warns **every** `match` on `shape` that doesn't handle `Triangle`
- You get a punch list of places to update
- This is **refactor-with-the-compiler's-help**:
  - Add a case
  - Compile
  - Fix every flagged site
  - When the warnings stop, the refactor is done

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

- A connection is in **one of four states**
- Each state carries the data relevant to *that* state
- `Listening`: no payload (just a tag)
- Others: carry what they need

(The `{ ... }` syntax is a variant constructor with an **inline record** payload; convenient for multi-field payloads.)

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

- `[]`: empty-list constructor
- `::`: cons constructor with two payloads (head, tail)
- List patterns like `x :: rest`: just **variant pattern matching**

`option` is a variant:

```
type 'a option = None | Some of 'a
```

- `None`: the "no value" constructor
- `Some x`: wraps a value
- Every list match you've written has been variant pattern matching

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

- Binary tree carrying values of any type `'a`
- `Leaf`: empty
- `Node (l, v, r)`: left subtree, value, right subtree
- Used in Module 4 lecture 4 (recursive types) and Module 5 (pattern matching)

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

- Results: `12.56...`, `9.0`, `20.0`
- `function` is shorthand for `fun x -> match x with ...`
- Common when a function's whole body is a `match` on its argument

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
