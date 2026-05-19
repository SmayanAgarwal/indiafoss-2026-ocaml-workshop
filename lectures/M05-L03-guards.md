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

- Each clause has a pattern (variable `n` or wildcard `_`).
- Optionally a guard (`when n > 0`).
- Clause matches if pattern matches **and** guard is `true`.

:::

:::slide

## Without guards, you'd nest `if`

- Without `when`, the same logic looks like:

```ocaml
let sign n =
  match n with
  | _ when n > 0 -> "positive"  (* same as below *)
  | _ ->
      if n < 0 then "negative"
      else "zero"
```

- Or worse: a chain of `if`/`else`.
- Guards keep cases lined up vertically: easier to read.

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

- Each clause destructures the pair **and** adds a predicate.
- Pattern selects the shape; guard filters further.

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

`true`, `false`, `false`.

- Guard `when x < 0` references `x`, bound by pattern `x :: _`.
- Guards can only use names from the **same clause's** pattern.

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

- The compiler can't know that `n > 0` and `n < 0` together cover every integer.
- It assumes a guard **can fail**.
- Can't prove exhaustiveness on its own.

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

- Same behaviour; no guard needed.
- Use `when` only when a pure pattern can't express the predicate:
  - Numeric inequalities.
  - String predicates.
  - Relationships between two bindings.

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

- Wildcard `_` at the bottom covers the zero case.
- Without it, the compiler warns about exhaustiveness.

:::

:::slide

## What's next

- Lecture 4: **exhaustiveness checking** in detail.
- We've seen "not exhaustive" warnings a few times.
- Next: how it works, why it's one of OCaml's most useful static checks.

:::

## Reading

- **Cornell CS3110**, *Pattern matching guards*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
