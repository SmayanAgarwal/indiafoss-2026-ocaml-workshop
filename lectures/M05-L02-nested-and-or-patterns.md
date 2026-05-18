---
title: "Nested patterns and or-patterns"
lecture_no: 2
week: 5
duration_target_min: 22
concepts: [nested patterns, or-patterns, tuple patterns inside variants, alternation]
keywords: [OCaml, pattern matching, nested patterns, or-patterns, alternation]
activity_question: "Write [first_of_pair_in_list : (int * int) list -> int option] returning the first component of the first pair, or [None] if the list is empty. Use nested patterns."
think_about_this: "An or-pattern lets multiple shapes share a right-hand side. What constraint does the compiler impose on the variables bound by each alternative?"
reading:
  - title: "Cornell CS3110, Pattern matching (continued)"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Nested patterns and or-patterns

Patterns *nest*. A pattern can contain other patterns. This lecture
covers nesting (the most common form is "look inside a constructor's
payload") and **or-patterns** (`p1 | p2`), which let multiple
shapes share a right-hand side.

:::slide

## Nesting: a pattern inside a constructor's payload

```ocaml
type point = { x : float; y : float }

let describe = function
  | { x = 0.0; y = 0.0 } -> "origin"
  | { x = 0.0; y = _   } -> "on the y-axis"
  | { x = _;   y = 0.0 } -> "on the x-axis"
  | { x = _;   y = _   } -> "somewhere else"

let _ = describe { x = 0.0; y = 0.0 }
let _ = describe { x = 3.0; y = 0.0 }
let _ = describe { x = 1.0; y = 2.0 }
```

`"origin"`, `"on the x-axis"`, `"somewhere else"`.

The patterns inside the record-pattern are themselves patterns: a
literal `0.0`, a wildcard `_`. Nested.

:::

:::slide

## Nesting: tuple inside variant

```ocaml
type shape =
  | Circle of float
  | Rectangle of float * float

let is_unit_circle = function
  | Circle 1.0 -> true
  | _ -> false

let _ = is_unit_circle (Circle 1.0)
let _ = is_unit_circle (Circle 2.0)
let _ = is_unit_circle (Rectangle (1.0, 1.0))
```

`true`, `false`, `false`. The pattern `Circle 1.0` requires both
the constructor to be `Circle` **and** its payload to be exactly
`1.0`. Two checks in one pattern.

:::

:::slide

## Nesting: list of pairs

```ocaml
let head_first = function
  | (x, _) :: _ -> Some x
  | [] -> None

let _ = head_first [(1, "a"); (2, "b"); (3, "c")]
let _ = head_first []
```

`Some 1`, `None`. The pattern `(x, _) :: _` matches a non-empty
list whose head is a pair; binds the first component of that pair
to `x`; ignores everything else. Three levels of nesting (list
cons, tuple, then the inner positions) in one pattern.

:::

Reading nested patterns is like reading nested HTML or JSON: take it
in from the outside and dive in. The pattern says: "the value is
a non-empty list (cons), and its head is a pair, and I'm naming the
first component of that pair `x`".

:::slide

## Or-patterns: same right-hand side for multiple shapes

```ocaml
let is_vowel = function
  | 'a' | 'e' | 'i' | 'o' | 'u' -> true
  | _ -> false

let _ = is_vowel 'a'
let _ = is_vowel 'b'
```

`true`, `false`. The clause's pattern is `'a' | 'e' | 'i' | 'o' |
'u'`: an *or* of five literal patterns. Any of them matching
triggers the same right-hand side.

Without or-patterns we'd write five clauses, each with the same
`true`. Much noisier.

:::

:::slide

## Or-patterns and variants

```ocaml
type direction = North | South | East | West

let is_horizontal = function
  | East | West -> true
  | North | South -> false

let _ = is_horizontal East
let _ = is_horizontal North
```

`true`, `false`. Two pairs, each sharing a right-hand side. The
function reads almost like English.

:::

:::slide

## Constraint: each alternative binds the same names

```ocaml skip
type pair = A of int | B of int

let _ =
  match A 5 with
  | A x | B y -> x   (* error: y not bound in left alternative *)
```

OCaml rejects this: an or-pattern requires all alternatives to bind
the same set of variables, with compatible types.

If both alternatives bind `x` with `int`, the right-hand side can
use `x`:

```ocaml
type pair = A of int | B of int

let to_int = function
  | A x | B x -> x

let _ = to_int (A 5)
let _ = to_int (B 7)
```

`5` and `7`. Both alternatives bind a single `int` to `x`; the
right-hand side returns `x`.

:::

:::slide

## Combining or-patterns and nesting

```ocaml
let summary = function
  | (0 | 1) :: _ -> "starts with 0 or 1"
  | _ :: _ -> "starts with something else"
  | [] -> "empty"

let _ = summary [0; 5; 6]
let _ = summary [1; 5; 6]
let _ = summary [5; 6]
let _ = summary []
```

`"starts with 0 or 1"`, `"starts with 0 or 1"`, `"starts with something else"`, `"empty"`.

The pattern `(0 | 1) :: _` reads "either 0 or 1, followed by
anything". Or-patterns can appear anywhere a pattern can: inside
constructors, tuples, lists.

:::

:::slide

## `as` patterns: name what you matched

Sometimes you want to *both* destructure a value *and* keep a name
for the whole thing:

```ocaml
let head_and_full = function
  | (x :: _) as xs -> Some (x, List.length xs)
  | [] -> None

let _ = head_and_full [10; 20; 30]
```

`Some (10, 3)`. The pattern `(x :: _) as xs` destructures the
non-empty list to get its head `x`, and also binds the *whole list*
to `xs`.

`as` is rare in everyday code; reach for it when you find yourself
about to write `match v with ... -> (something, v)`.

:::

:::slide

## Activity

Write `first_of_pair_in_list : (int * int) list -> int option`
returning the first component of the first pair, or `None` if the
list is empty. Use a nested pattern.

:::

:::slide

## Activity solution

```ocaml
let first_of_pair_in_list = function
  | (x, _) :: _ -> Some x
  | [] -> None

let _ = first_of_pair_in_list [(10, 20); (30, 40)]
let _ = first_of_pair_in_list []
```

`Some 10`, `None`. The pattern `(x, _) :: _` is:

- `_` on the left of `::` would be "the head"; here we want to
  destructure that head, so we write `(x, _)` instead.
- `_` on the right of `::` is "the rest of the list, ignored".

Read inside-out: a list whose head is a pair, whose first
component is bound to `x`.

:::

:::slide

## What's next

Lecture 3: **guards** (`when`-clauses). Patterns can be combined
with arbitrary boolean tests, which lets you express conditions
that pure patterns can't.

:::

## Reading

- **Cornell CS3110**, *Pattern matching (continued)*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
