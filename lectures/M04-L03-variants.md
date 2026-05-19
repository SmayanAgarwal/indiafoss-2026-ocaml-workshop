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
  - title: "Cornell CS3110, Algebraic data types"
    url: https://cs3110.github.io/textbook/chapters/data/algebraic_data_types.html
  - title: "Real World OCaml, Variants"
    url: https://dev.realworldocaml.org/variants.html
---

# Variants (sum types)

[Tuples](M04-L01-tuples.html) and
[records](M04-L02-records.html) express *and*: a 2D point has an
`x` *and* a `y`; a person has a name *and* an age *and* an email.
Variants express *or*: a `shape` is a circle *or* a square *or* a
rectangle; the result of parsing is a success *or* a failure; a
value in an arithmetic expression is a number *or* a sum *or* a
product. Almost every interesting data type you will design in
OCaml is a combination of these two: variants for the "kinds,"
records (or tuples) for the data inside each kind.

The name *variant* refers to the fact that a value of a variant
type *varies* between several possibilities. The names *sum type*
and *disjoint union* refer to the underlying set theory: the set
of values of a variant is the disjoint union of the sets of values
of its alternatives. The two names you will hear most often in
practice are *variant* (OCaml's term) and *tagged union* (the
implementation view: each value carries a tag identifying which
alternative it is, plus the payload data for that alternative).
*Algebraic data type* is the umbrella term that combines variants
and records.

If you have used C, the closest analogue is `enum` plus a tagged
`union` plus the programmer discipline to keep the tag and the
union consistent. OCaml folds all three into a single declaration
and asks the compiler to enforce the consistency. If you have used
Rust, the same idea appears as `enum`; if you have used Java with
sealed interfaces or Kotlin with sealed classes, the same idea
appears there too. Each of these is following the lead of the
ML family, where variants have been around since the 1970s.

## Declaring a variant: the enum case

The simplest variant is one whose alternatives carry no data:

```ocaml
type direction = North | South | East | West

let d = North
```

Four *constructors* (`North`, `South`, `East`, `West`), separated
by `|`. A value of type `direction` is exactly one of these four.

:::slide

## Declaring a variant

```ocaml
type direction = North | South | East | West

let d = North
```

- Four *constructors*, separated by `|`.
- Each is a distinct value of type `direction`.
- Constructors are **capitalized** (always start with a capital).
- A `direction` value holds *exactly one* of the four.
- This is what an `enum` looks like in C or Java.

:::

The capitalisation is mandatory: OCaml uses the first character of
an identifier to distinguish a *constructor* (starts with capital,
denotes a variant case) from a *variable* (starts with lowercase,
denotes a binding). The compiler tells the two apart by lexical
rule alone, which saves you from ambiguity later when you pattern
match.

A value of type `direction` is just one of the four named tags.
There is no implicit numeric encoding (C lets you write `North = 0`
and treat directions as ints; OCaml does not). If you want a
mapping to ints, write a function:

```ocaml
type direction = North | South | East | West

let int_of_direction = function
  | North -> 0
  | South -> 1
  | East  -> 2
  | West  -> 3
```

This is more verbose than C's implicit enumeration, but it is
explicit: the mapping is in *one place* and the compiler will
warn you if you forget a case.

## Constructors with payload

A variant becomes much more interesting when its constructors carry
data. This is the syntax for *attaching* data to a constructor:

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let c = Circle 3.0
let s = Square 5.0
let r = Rectangle (4.0, 6.0)
```

Each `of TYPE` clause specifies what data the constructor carries.
`Circle of float` says "a `Circle` carries one `float` (its
radius)"; `Rectangle of float * float` says "a `Rectangle` carries
two `float`s (its width and height)."

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

- `Circle` carries one `float` (radius).
- `Square` carries one `float` (side length).
- `Rectangle` carries two `float`s (width, height).
- `Circle 3.0`, `Square 5.0`: both values of type `shape`.
- Constructor: *which kind* of shape. Payload: data for that kind.

:::

A constructor is *applied* to its payload by juxtaposition (like a
function call without parentheses): `Circle 3.0`, `Square 5.0`. For
constructors that take multiple components, the payload is a tuple,
wrapped in parens: `Rectangle (4.0, 6.0)`. The parentheses around
the tuple are required when the tuple has more than one component
and the constructor takes a tuple payload.

A subtle but important point: `Rectangle` does *not* take two
arguments. It takes *one* argument, which happens to be a pair. The
type `float * float` in `of float * float` is a single tuple type,
not "two arguments." This matters for pattern matching: you write
`Rectangle (w, h)` (one pair-pattern, parens required), not
`Rectangle w h` (which would not parse).

## Pattern matching on variants

Once you have a variant, the way to use it is to *pattern match*
on which constructor was used:

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let area s =
  match s with
  | Circle r -> Float.pi *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h

let _ = area (Circle 3.0)
let _ = area (Rectangle (4.0, 6.0))
```

The `match ... with` expression inspects a value and dispatches
based on its shape. Each `| PATTERN -> EXPRESSION` clause says
"if the value matches this pattern, then this expression is the
result." The patterns here mirror the constructor syntax: `Circle
r` matches any `Circle` and binds its payload to `r`; `Rectangle
(w, h)` matches any `Rectangle` and binds its two components.

:::slide

## Pattern matching on variants

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float
let area s =
  match s with
  | Circle r -> Float.pi *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h
```

- `match` inspects which constructor was used.
- Binds the payload to local names.
- Like a `switch` in C, with two upgrades:
  - Compiler checks **every** constructor is handled.
  - You can **destructure** the payload at the same time.

:::

If you have written `switch` in C or `case` in Pascal, this should
look familiar in structure. Two things make `match` more powerful
than either:

1. **[Exhaustiveness checking](M05-L04-exhaustiveness.html).** The
   compiler tracks the variant declaration and warns if you forget
   a case.
2. **Destructuring.** You bind the payload data in the pattern,
   not in a separate statement. This eliminates a class of "I
   forgot to extract the field" bugs.

This combination of variants and pattern matching is the *engine*
of nearly every interesting OCaml program. Interpreters, parsers,
type checkers, compilers, network protocol decoders, configuration
loaders, web routers: all of these have data that comes in
*several distinct shapes*, and OCaml's idiom for that is always
the same: a variant, plus pattern matching.

## Exhaustiveness checking

Forgetting a case in a `match` is a real bug. OCaml's compiler
catches it for you:

```ocaml skip
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let area s =
  match s with
  | Circle r -> Float.pi *. r *. r
  | Square s -> s *. s
```

The compiler emits:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Rectangle (_, _)
```

:::slide

## Exhaustiveness checking

If you forget a case:

```ocaml skip
let area s =
  match s with
  | Circle r -> Float.pi *. r *. r
  | Square s -> s *. s
```

Warning:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
Rectangle (_, _)
```

- Compiler flags that `Rectangle` is unhandled.
- Tells you the *shape* of the missing case.
- Catches a class of bugs **statically**, before any test runs.
- Stricter projects turn this warning into an **error**.
- Forgetting a case becomes a compile failure.

:::

The warning gives you a counterexample (`Rectangle (_, _)`) to help
you find what is missing. In real codebases, you almost always
want to promote this warning to an *error*: a partial match is a
latent crash, and the compiler is offering to find them for you.
The dune build option for this is `(flags (:standard -strict-sequence
-strict-formats -w +8))`, but you do not need to know that
syntax now. The
[exhaustiveness lecture in Module 5](M05-L04-exhaustiveness.html#treating-warnings-as-errors)
covers turning the warning into an error; for now, just know the
option exists.

The catch-all wildcard pattern `_` matches anything, and the
compiler will accept it as covering all remaining cases:

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let is_round = function
  | Circle _ -> true
  | _ -> false
```

This is sometimes appropriate (here, we genuinely treat all
non-circles the same). But it has a dangerous downside, covered
next.

## The catch-all-case trap

The wildcard `_` defeats exhaustiveness checking. If you later
add a new constructor to the variant, every `match` that uses
`_` will *silently* lump the new constructor in with the wildcard
case, rather than warning that you forgot to handle it. This is a
real bug pattern.

Suppose you start with:

```ocaml
type color = Red | Blue

(* somewhere far away in the codebase: *)
let name = function
  | Red -> "red"
  | _ -> "blue"
```

Now you add a new colour:

```ocaml skip
type color = Red | Blue | Green

let name = function
  | Red -> "red"
  | _ -> "blue"
```

The `name` function compiles without complaint and silently
returns `"blue"` for `Green`. The compiler does not warn because
the match *is* exhaustive (the wildcard catches `Green`). You have
introduced a silent bug.

:::slide

## The catch-all trap

```ocaml
type color = Red | Blue
let name = function
  | Red -> "red"
  | _ -> "blue"
```

Now add `Green`:

```ocaml skip
type color = Red | Blue | Green
let name = function
  | Red -> "red"
  | _ -> "blue"
```

- Compiles, no warning.
- Silently calls `Green` "blue".
- The wildcard `_` defeats exhaustiveness checking.

**Rule:** prefer to list constructors explicitly, especially in
small public functions. Use `_` only when the wildcard truly
captures intent (e.g., `_ -> false` for "anything else is not a
circle").

:::

The lesson, as Real World OCaml puts it: *catch-all cases lead to
buggy code*. Reach for explicit constructor patterns by default;
use `_` only when "anything else" is genuinely the meaning, and
the meaning is stable in the face of future additions to the
variant. We come back to this trade-off in
[M05-L04](M05-L04-exhaustiveness.html#when-to-use-a-wildcard-catch-all-on-variants).

## Adding a case: refactor with the compiler

When you *do* list constructors explicitly, adding a new case
turns into a delightful experience: the compiler tells you exactly
where else in the codebase needs updating.

Suppose we add `Triangle`:

```ocaml skip
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float
  | Triangle of float * float * float

let area s =
  match s with
  | Circle r -> Float.pi *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h
```

The compiler now warns on `area`: "non-exhaustive: missing
`Triangle (_, _, _)`". It will also warn on every *other* function
that pattern-matches on `shape`. You add a case, recompile, fix
each flagged site, repeat until the warnings stop. When the
warnings stop, the refactor is done.

:::slide

## Adding a case

Add `Triangle`:

```ocaml skip
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float
  | Triangle of float * float * float
```

- Compiler warns **every** `match` on `shape` that doesn't handle `Triangle`.
- You get a punch list of places to update.
- This is **refactor-with-the-compiler's-help**:
  1. Add a case.
  2. Compile.
  3. Fix every flagged site.
  4. When warnings stop, the refactor is done.

:::

This is one of the everyday wins of working in a typed functional
language. In Python or JavaScript, adding a new "kind" of value to
some category requires you to grep the codebase, hope you found
every dispatch site, and probably write a test. In OCaml, the
compiler does the grep for you and refuses to let you forget.

## Constructors with multi-field payloads: inline records

When a constructor's payload has more than one or two components,
the tuple form (`Constructor of t1 * t2 * t3`) becomes unwieldy.
For these cases, OCaml supports *inline records* as constructor
payloads:

```ocaml
type tcp_state =
  | Listening
  | Connecting of { peer : string }
  | Connected of { peer : string; bytes_sent : int }
  | Closed of { reason : string }
```

Each non-trivial state carries the data relevant to that state, and
each piece of data has a name. To extract the data, pattern matching
works as before, with the inline-record syntax in the pattern:

```ocaml
type tcp_state =
  | Listening
  | Connecting of { peer : string }
  | Connected of { peer : string; bytes_sent : int }
  | Closed of { reason : string }

let describe = function
  | Listening -> "listening"
  | Connecting { peer } -> "connecting to " ^ peer
  | Connected { peer; bytes_sent } ->
      Printf.sprintf "connected to %s, sent %d bytes" peer bytes_sent
  | Closed { reason } -> "closed: " ^ reason
```

:::slide

## Constructors with named-field payloads

```ocaml
type tcp_state =
  | Listening
  | Connecting of { peer : string }
  | Connected of { peer : string; bytes_sent : int }
  | Closed of { reason : string }
```

- A connection is in **one of four states**.
- Each state carries the data relevant to *that* state.
- `Listening`: no payload.
- Others: carry what they need.
- `{ ... }` after `of` is an **inline record** payload.
- Use for multi-field payloads where names are clearer than positions.

:::

This is OCaml's version of Rust's struct-style enums:

```rust
enum TcpState {
    Listening,
    Connected { peer: String, bytes_sent: usize },
}
```

The inline record syntax was added to OCaml in 4.03 (2016) and has
become idiomatic for variant payloads of more than two pieces of
data.

## Variants you have already used

OCaml's built-in `bool`, `list`, and `option` types are all
variants. You have been pattern-matching on them since Module 3
without us calling out that this is *variant pattern matching*.

The `bool` type:

```
type bool = false | true
```

(More or less; the constructors are lowercase by special
dispensation given that `bool` is so primitive. You usually use
`true` and `false` as values, but they are technically the two
constructors of the variant `bool`.)

The `list` type:

```
type 'a list = [] | (::) of 'a * 'a list
```

`[]` is the empty-list constructor; `::` is the cons constructor,
which takes a pair of an element and a smaller list. Every list
pattern you have written: `[] -> ...` or `x :: rest -> ...`, is a
variant pattern. The reason `list` is a *recursive* variant (the
type refers to itself inside `::`) is the topic of the
[next lecture](M04-L04-recursive-types.html).

The `option` type:

```
type 'a option = None | Some of 'a
```

`None` is "no value"; `Some x` wraps a value. We will give `option`
its own treatment in
[M04-L05](M04-L05-option-and-aliases.html#the-option-type).

:::slide

## Built-in variants

`bool` is a variant:

```
type bool = false | true
```

`list` is a recursive variant:

```
type 'a list = [] | (::) of 'a * 'a list
```

- `[]`: empty-list constructor.
- `::`: cons constructor with two payloads (head, tail).
- List patterns like `x :: rest` are **variant pattern matching**.

`option` is a variant:

```
type 'a option = None | Some of 'a
```

- Every list match you've written has been variant pattern matching.

:::

The lesson: variants are not a corner feature you reach for
occasionally. They are *pervasive* in OCaml. The standard library
is full of them, and your own code will be too.

## Parameterised variants

A variant declaration can be parameterised by one or more type
variables, just like a function can be parameterised by its
arguments. `list` and `option` are examples: `'a list` works for
any element type `'a`. You can declare your own:

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

The type `'a tree` is a binary tree carrying values of type `'a`
at each internal node. `int tree` is a tree of integers, `string
tree` is a tree of strings, and so on. We will see trees again in
the [next lecture](M04-L04-recursive-types.html#a-binary-tree)
(they are the canonical example of a *recursive* variant).

:::slide

## Parameterised variants

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

- Binary tree carrying values of any type `'a`.
- `Leaf`: empty.
- `Node (l, v, r)`: left subtree, value, right subtree.
- Used in M04-L04 (recursive types) and Module 5 (pattern matching).

:::

The slogan you will hear in functional programming circles is
*make illegal states unrepresentable*. A well-designed variant
type allows only the configurations the domain actually permits,
and rules out the rest by construction. Compare:

- *Bad:* `type connection = { state : string; peer : string option;
  bytes_sent : int option; close_reason : string option }`.
  Nothing prevents `{ state = "listening"; bytes_sent = Some 42; ... }`,
  which is nonsense.
- *Good:* the `tcp_state` variant above. Each state carries
  precisely the data it needs and no more. There is no way to
  build a "Listening with bytes_sent" value.

This is the design principle Module 4 was put together to teach.
You will see it again in
[Module 7](M07-L05-signatures.html#why-hide-internals) when we
discuss API design.

## A small check

:::quiz mcq
Given:

```ocaml
type result_kind =
  | Ok of int
  | Err of string
```

Which of these patterns does `Ok 0` match?

- [ ] `Err _`
- [x] `Ok _`
- [x] `Ok n` (binding `n` to `0`)
- [ ] Both `Ok` and `Err`.

**Why:** `Ok 0` is built from the `Ok` constructor with payload `0`.
It matches `Ok _` (any `Ok`), and it matches `Ok n` (any `Ok`,
binding the payload to `n`). It does *not* match `Err _`.
:::

:::quiz code
Define the variant `coin` and write `value : coin -> int` returning
the value in paise: `Paisa1` is `1`, `Paisa5` is `5`, `Paisa10` is
`10`, `Rupee` is `100`.

```ocaml
type coin = Paisa1 | Paisa5 | Paisa10 | Rupee

let value c =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (value Paisa1 = 1) "1p";
  check (value Paisa5 = 5) "5p";
  check (value Paisa10 = 10) "10p";
  check (value Rupee = 100) "Re";
  print_endline "all tests passed"
```
:::

Reference solution:

```ocaml
type coin = Paisa1 | Paisa5 | Paisa10 | Rupee
let value = function
  | Paisa1 -> 1
  | Paisa5 -> 5
  | Paisa10 -> 10
  | Rupee -> 100
```

## Activity

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
  | Circle r -> Float.pi *. r *. r
  | Square s -> s *. s
  | Rectangle (w, h) -> w *. h

let _ = area (Circle 2.0)
let _ = area (Square 3.0)
let _ = area (Rectangle (4.0, 5.0))
```

- Three constructors. Three pattern clauses. One per case.
- `function` is shorthand for `fun x -> match x with ...`.
- Common when a function's whole body is a `match` on its argument.

:::

The `function` keyword introduces an anonymous function that
immediately pattern matches on its (single, implicit) argument. It
is equivalent to `fun x -> match x with ...` but shorter. We will
see more of `function` (and pattern matching more generally) in
[Module 5](M05-L01-basic-patterns.html#function-shorthand).

## What's next

:::slide

## What's next

Lecture 4: **recursive types**. Variants whose payloads include
the type being defined. Lists and trees both fit this shape, as do
arithmetic expressions, JSON values, and more. The recursive case
is what makes algebraic data types *powerful*, not just *labelled*.

:::

We have seen variants with *fixed* payloads: a `Circle` always
carries one float. The
[next lecture](M04-L04-recursive-types.html) lets a constructor's
payload include a value of *the type being defined*. That is the
doorway to lists, trees, and arbitrary tree-shaped data.

## Reading

- **Cornell CS3110**, *Variants*:
  <https://cs3110.github.io/textbook/chapters/data/variants.html>
- **Cornell CS3110**, *Algebraic data types*:
  <https://cs3110.github.io/textbook/chapters/data/algebraic_data_types.html>
- **Real World OCaml**, *Variants*:
  <https://dev.realworldocaml.org/variants.html>
