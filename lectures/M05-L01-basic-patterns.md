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

- `match` takes a value and a list of clauses.
- Each clause has a **pattern** (left) and an **expression** (right).
- The **first pattern that matches wins**.
- Its right-hand side becomes the value of the whole `match`.

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

- Pattern `n` matches anything.
- The right-hand side uses `n` to reference the matched value.

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

`"variable: 0"`.

- Variable pattern `x` matches *anything*, including `0`.
- Once matched, the second clause is **unreachable**.
- OCaml warns:

```
Warning 11: this match case is unused.
```

- Rule: **specific patterns first**, *general* patterns last.

:::

:::slide

## When to use `_` vs a variable name

```ocaml
let first_only = function
  | (x, _) -> x

let _ = first_only (10, 20)
```

`int = 10`.

- Second component discarded; `_` makes that explicit.
- Writing `(x, y)` triggers a warning that `y` is unused:

```
Warning 26: unused variable y.
```

- `_` says "I know I'm ignoring this"; the compiler respects it.

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

`"north"` and `"unknown"`.

- The wildcard catches every other string.
- No name needed for the catch-all case.

:::slide

## `function` shorthand

- When a one-arg function's whole body is a `match` on the argument, use `function`.

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

- Idiomatic OCaml uses `function` heavily.

:::

:::slide

## A pattern *is* an expression's structure

- Patterns aren't just for `match`.
- `let` also takes a pattern on the left.

```ocaml
let (x, y) = (3, 4)
let _ = x + y
```

- `x` and `y` are bound by destructuring the pair.

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

- The compiler shows a sample input that no clause covers.
- Fix: add more clauses or a catch-all `_`.
- Lecture 4 covers exhaustiveness in detail.

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

- Variable pattern `x` matches *any* integer, including `0`.
- `x` appears first, so it wins; second clause is unreachable (warning 11).
- `f 0` returns `0`; `f 5` returns `5`.

The fix: put `0` first.

```ocaml skip
let f = function
  | 0 -> 99
  | x -> x
```

- Now `f 0` returns `99`; `f n` returns `n` otherwise.

:::

:::slide

## What's next

- Lecture 2: **nested patterns and or-patterns**.
- Patterns can contain other patterns.
- `|` inside a clause lets multiple shapes share a right-hand side.

:::

## Reading

- **Cornell CS3110**, *Pattern matching*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
