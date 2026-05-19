---
title: "Exhaustiveness checking"
lecture_no: 4
week: 5
duration_target_min: 22
concepts: [exhaustiveness, partial match, redundant clauses, refactor with the compiler]
keywords: [OCaml, exhaustiveness, pattern matching, warning 8, warning 11]
activity_question: "What does the compiler do when you add a new constructor to a variant type that is matched in 12 places? Why is that the strongest argument for using variants instead of strings or ints to encode kinds?"
think_about_this: "Exhaustiveness checking is a *warning*, not an error, by default. Why? Should it be an error in your projects? What's the practical trade-off?"
reading:
  - title: "Cornell CS3110, Exhaustiveness"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Exhaustiveness checking

The pattern-matching compiler in OCaml does more than dispatch on
shape. It checks that your clauses cover every possible input, and
warns you when they don't. This is one of the most useful
static-analysis features in any production language, and the
reason why algebraic data types pay off in real codebases.

:::slide

## A non-exhaustive match

```ocaml skip
type traffic_light = Red | Yellow | Green

let action = function
  | Red -> "stop"
  | Green -> "go"
```

OCaml warns:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: Yellow
```

- The compiler tells you *which* case is missing.
- Add the missing clause:

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
```

- Warning gone.
- The function now handles every possible `traffic_light`.

:::

:::slide

## Why this matters

- The compiler **proves** no `traffic_light` falls through at runtime.
- Without exhaustiveness checking, a missing case becomes a runtime crash:
  - **C** (switch + enum): missing case falls through; depends on what's next.
  - **Java** (switch): same, unless a linter check is enabled.
  - **Python**: no static checking; runtime `KeyError`/`AttributeError`.
- OCaml flags the problem **before** the program runs.

:::

:::slide

## Refactor with the compiler

```ocaml skip
type traffic_light = Red | Yellow | Green | FlashingRed
```

- Every `match` on `traffic_light` warns about the new case.
- Add the clause to each:

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
  | FlashingRed -> "stop, then proceed with caution"
```

- The compiler points at every site that needs updating.
- Refactoring goes from "grep and pray" to "compile and fix the warnings".

:::

This is the property that *justifies* using variants for finite
kinds, even when a string would feel easier. With a string-based
representation (`light = "red"`, `light = "green"`), the compiler
cannot help when you add a fourth kind: it has no idea what set of
strings is valid. With a variant, every match is automatically a
case-coverage check.

:::slide

## Redundant clauses

- Dual of "missing a case" is "duplicating a case".

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
  | Red -> "redundant"

let _ = action Red
```

- Warning 11: this match case is unused.
- The second `Red` clause is **dead**; the compiler catches it.

:::

:::slide

## Variable patterns shadow specific patterns

```ocaml skip
let label = function
  | n -> "got " ^ string_of_int n
  | 0 -> "zero"

let _ = label 0
```

- First clause `n` (variable) matches anything.
- Second clause `0` is unreachable. Warning 11.

The fix: swap them.

```ocaml
let label = function
  | 0 -> "zero"
  | n -> "got " ^ string_of_int n

let _ = label 0
```

- Rule: **specific-first, general-last**.

:::

:::slide

## Exhaustiveness on multi-component patterns

```ocaml skip
let category = function
  | (true, true)  -> "both"
  | (true, false) -> "only first"
  | (false, true) -> "only second"

let _ = category (false, false)
```

Compiler warns:

```
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: (false, false)
```

- Even with a tuple of small types, the compiler enumerates unhandled combinations.
- Fix: add `(false, false) -> "neither"` (or a wildcard).

:::

:::slide

## Treating warnings as errors

- In real projects, treat partial-match warnings as errors.
- Add to your dune file:

```
(executable
 (name foo)
 (flags (:standard -w +a-3-49)))
```

- Or workspace-wide: `(env (_ (flags (:standard -w +a-3-49))))`.
- `-w +a` makes all warnings errors; `-3-49` disables benign ones.
- Module 7 covers dune; for now, know this is the default in serious codebases.

:::

:::slide

## Activity

Suppose you have a variant type `color = Red | Green | Blue` that
is matched in twelve places across a codebase. You now want to
add a fourth case, `Yellow`. How does the OCaml compiler help, and
what does it *not* help with?

:::

:::slide

## Activity discussion

The compiler:

- Issues warning 8 at *every* match on `color` that misses `Yellow`. One punch-list line per match.
- Tells you the missing case (`Yellow`) by example.
- Does **not** tell you *what behaviour* `Yellow` should produce (that's a design decision).

Takeaways:

- Structural completeness: mechanically checked.
- Semantic correctness: up to you.
- The compiler answers "where?", not "what?".
- Biggest practical reason to use **variants** for finite kinds; strings can't give this guarantee.

:::

:::slide

## What's next

- Lecture 5: **matching records and variants** in more depth.
- Daily syntax: short forms, ignoring unrelated fields, deeply nested cases.

:::

## Reading

- **Cornell CS3110**, *Exhaustiveness*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
