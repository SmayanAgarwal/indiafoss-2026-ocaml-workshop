---
title: "Guards: when-clauses on patterns"
lecture_no: 3
week: 5
duration_target_min: 20
concepts: [when-guards, conditional pattern matching, exhaustiveness with guards]
keywords: [OCaml, pattern matching, when, guard, conditional pattern]
activity_question: "Write [sign : int -> string] returning \"negative\", \"zero\", or \"positive\". Use a single match with when-clauses (no if/else)."
think_about_this: "Guards turn pattern matching into pattern+predicate matching. What does the compiler's exhaustiveness checker conservatively assume about a clause guarded by [when]? Why must it?"
reading:
  - title: "Cornell CS3110, Pattern matching guards"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Guards: when-clauses on patterns

A pattern by itself can only match on *shape*: this constructor,
this literal, a wildcard. To match based on a *computation* (`n >
0`, `String.length s > 5`), you add a **guard** with `when`.

:::slide

## A guard adds a predicate to a clause

```ocaml
let sign = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"

let _ = sign 5
let _ = sign (-3)
let _ = sign 0
```

`"positive"`, `"negative"`, `"zero"`.

Each clause has a pattern (here, the variable `n` or the wildcard
`_`) and optionally a guard (`when n > 0`). A clause matches if
both the pattern matches *and* the guard evaluates to `true`.

:::

:::slide

## Without guards, you'd nest `if`

Without `when`, the same logic looks like:

```ocaml
let sign n =
  match n with
  | _ when n > 0 -> "positive"  (* same as below *)
  | _ ->
      if n < 0 then "negative"
      else "zero"
```

or even worse: a chain of `if`/`else`. Guards keep the cases lined
up vertically, which is easier to read.

:::

:::slide

## Guards on more interesting patterns

```ocaml
let report = function
  | (x, y) when x = y    -> "diagonal"
  | (x, _) when x = 0    -> "on the y-axis"
  | (_, y) when y = 0    -> "on the x-axis"
  | _                    -> "elsewhere"

let _ = report (1, 1)
let _ = report (0, 5)
let _ = report (3, 0)
let _ = report (2, 4)
```

`"diagonal"`, `"on the y-axis"`, `"on the x-axis"`, `"elsewhere"`.

Each clause destructures the pair *and* adds a predicate on the
extracted components. The pattern selects the shape; the guard
filters further.

:::

:::slide

## Guards see only what the pattern bound

```ocaml
let starts_negative = function
  | [] -> false
  | x :: _ when x < 0 -> true
  | _ -> false

let _ = starts_negative [-3; 5; 7]
let _ = starts_negative [1; 2; 3]
let _ = starts_negative []
```

`true`, `false`, `false`. The guard `when x < 0` references `x`,
which was bound by the pattern `x :: _`. You can only use names
that the pattern in the *same clause* introduced.

:::

:::slide

## Exhaustiveness with guards is conservative

```ocaml skip
let classify n =
  match n with
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
```

OCaml warns:

```
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: 0
```

The compiler can't know that `n > 0` and `n < 0` together cover
every integer. It assumes a guard can fail, so it can't prove
exhaustiveness on its own.

You must add the explicit zero case (or a wildcard):

```ocaml
let classify = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"
```

:::

The conservatism is the price of allowing arbitrary computation in a
guard. The compiler can prove that `Circle r` and `Rectangle (w,
h)` cover every `shape` (because the type system says so). It
cannot prove that `n > 0 || n < 0 || n = 0`, because that's
arithmetic, not type theory.

:::slide

## Don't reach for guards when a pattern would do

```ocaml
let is_origin = function
  | (x, y) when x = 0.0 && y = 0.0 -> true
  | _ -> false
```

Functional, but unwieldy. The pattern alternative is cleaner:

```ocaml
let is_origin = function
  | (0.0, 0.0) -> true
  | _ -> false
```

Same behaviour; no guard needed because the literal pattern does
the work. Reach for `when` only when the predicate cannot be a
pure pattern: numeric inequalities, string predicates,
relationships between two bindings.

:::

:::slide

## Activity

Write `sign : int -> string` returning `"negative"`, `"zero"`, or
`"positive"`. Use a single `match` with `when`-clauses; no `if`/
`else`.

:::

:::slide

## Activity solution

```ocaml
let sign = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"

let _ = sign 7
let _ = sign (-3)
let _ = sign 0
```

`"positive"`, `"negative"`, `"zero"`.

The wildcard `_` at the bottom covers the only remaining case
(zero). Without it, the compiler warns about exhaustiveness.

:::

:::slide

## What's next

Lecture 4: **exhaustiveness checking** in detail. We saw the
"this pattern-matching is not exhaustive" warning a few times. The
next lecture shows how it works and why it is one of the most
useful pieces of static checking OCaml offers.

:::

## Reading

- **Cornell CS3110**, *Pattern matching guards*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
