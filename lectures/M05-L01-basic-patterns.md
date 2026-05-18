---
title: "Basic patterns: literals, variables, wildcards"
lecture_no: 1
week: 5
duration_target_min: 22
concepts: [pattern matching, match expression, literal patterns, variable patterns, wildcard]
keywords: [OCaml, pattern matching, match, wildcard, _, literal pattern]
activity_question: "Why does [match 0 with | x -> x | 0 -> 99] always return 0, no matter what? Which clause runs?"
think_about_this: "A variable pattern always matches anything and binds the matched value to that name. What happens when a variable pattern is *followed by* a more specific pattern? Which wins?"
reading:
  - title: "Cornell CS3110, Pattern matching"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Basic patterns

You have been writing `match ... with` and `let (x, y) = ...` since
Module 2. This lecture and the next four put pattern matching at
the centre. We start with the simplest building blocks: matching on
literals, binding variables, and the wildcard `_`.

:::slide

## The shape of `match`

```ocaml
let classify n =
  match n with
  | 0 -> "zero"
  | 1 -> "one"
  | 2 -> "two"
  | _ -> "many"

let _ = classify 1
let _ = classify 5
```

`"one"` and `"many"`.

`match` takes a value and a list of clauses. Each clause is a
**pattern** on the left and an **expression** on the right. The
first pattern that matches wins; its right-hand side is the value
of the whole `match` expression.

:::

:::slide

## Three kinds of pattern in this lecture

1. **Literal patterns**: `0`, `'a'`, `"hello"`, `true`. Match exactly
   that value.
2. **Variable patterns**: any name starting with a lowercase letter
   (`x`, `result`, `_data`). Matches anything; binds the matched
   value to that name on the right-hand side.
3. **Wildcard `_`**: matches anything; binds nothing. Use when you
   don't care about the value.

```ocaml
let _ =
  match 42 with
  | 0 -> "zero"
  | n -> "non-zero: " ^ string_of_int n
```

The second clause's pattern `n` matches anything; the right-hand
side uses `n` to reference the matched value.

:::

:::slide

## Order matters

```ocaml skip
let classify n =
  match n with
  | x -> "variable: " ^ string_of_int x
  | 0 -> "this never fires"

let _ = classify 0
```

`"variable: 0"`. The variable pattern `x` matches *anything*,
including `0`. Once it has matched, the second clause is
unreachable. OCaml will warn you:

```
Warning 11: this match case is unused.
```

Always put more *specific* patterns first, and more *general*
patterns last.

:::

:::slide

## When to use `_` vs a variable name

```ocaml
let first_only = function
  | (x, _) -> x

let _ = first_only (10, 20)
```

`int = 10`. The second component is discarded; we use `_` to make
that explicit.

If we'd written `(x, y)`, OCaml would warn that `y` is unused:

```
Warning 26: unused variable y.
```

The `_` is "I know I'm ignoring this", which the compiler
respects.

:::

`_` is also useful when several patterns are mutually exclusive
and you want a catch-all:

```ocaml
let direction_label = function
  | "n" -> "north"
  | "s" -> "south"
  | "e" -> "east"
  | "w" -> "west"
  | _ -> "unknown"

let _ = direction_label "n"
let _ = direction_label "x"
```

`"north"` and `"unknown"`. The wildcard catches every other string,
without forcing us to give it a name.

:::slide

## `function` shorthand

When the entire body of a one-argument function is a `match` on
the argument, write `function` instead:

```ocaml
let classify = function
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "many"
```

is the same as:

```ocaml
let classify n =
  match n with
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "many"
```

You'll see `function` a lot in idiomatic OCaml.

:::

:::slide

## A pattern *is* an expression's structure

Patterns aren't just for `match`. The `let` form also takes a
pattern on the left:

```ocaml
let (x, y) = (3, 4)
let _ = x + y
```

`x` and `y` are bound by destructuring the pair. The "pattern"
here is `(x, y)`.

Function parameters can also be patterns:

```ocaml
let sum (a, b) = a + b

let _ = sum (3, 4)
```

`int = 7`. The parameter pattern destructures the pair.

:::

:::slide

## Exhaustiveness, lightly

```ocaml skip
let label = function
  | 0 -> "zero"
  | 1 -> "one"
```

OCaml warns:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: 2
```

The compiler tells you a sample of an input that no clause covers.
You can fix by adding more clauses or a catch-all `_`. We'll cover
exhaustiveness in detail in Lecture 4.

:::

:::slide

## Activity

Why does the following always return `0`, regardless of which clause
order seems to suggest?

```ocaml skip
let f = function
  | x -> x
  | 0 -> 99
```

(Then call `f 0` and `f 5`.)

:::

:::slide

## Activity discussion

The variable pattern `x` matches *any* integer, including `0`. It
appears first, so it wins. The second clause is unreachable;
OCaml issues warning 11.

`f 0` returns `0` (matched the variable pattern with `x = 0`).
`f 5` returns `5` (matched the variable pattern with `x = 5`).

The fix: put `0` first.

```ocaml skip
let f = function
  | 0 -> 99
  | x -> x
```

Now `f 0` returns `99` and `f n` returns `n` for any other `n`.

:::

:::slide

## What's next

Lecture 2: **nested patterns and or-patterns**. Patterns can
contain other patterns; `|` inside a clause lets multiple shapes
share a right-hand side.

:::

## Reading

- **Cornell CS3110**, *Pattern matching*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
