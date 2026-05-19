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

Of all the static checks the OCaml compiler performs, the one
you will come to value most is *exhaustiveness*. The compiler
looks at every `match` you write and asks: "do these clauses
cover every possible value of the matched type?" If the answer
is no, it warns you, and it tells you which case you missed. If
the answer is yes, it stays quiet.

This sounds like a small convenience. It is in fact the most
important property your type system can give you, and it is the
single biggest reason to prefer [variants](M04-L03-variants.html)
over ad-hoc encodings (strings, integers, "magic numbers") for
finite kinds. Once you have used it in anger on a real codebase
(adding a new constructor to a variant and watching the compiler
enumerate every place that needs updating), you will not want to
write production code without it.

This lecture covers what exhaustiveness checking is, how to read
the warnings, the dual check for redundant clauses, and the
practical advice on turning warnings into errors for serious
projects.

## A non-exhaustive match

Take the traffic-light example from [Module 4](M04-L03-variants.html#exhaustiveness-checking):

```ocaml skip
type traffic_light = Red | Yellow | Green

let action = function
  | Red -> "stop"
  | Green -> "go"
```

We forgot `Yellow`. The compiler tells us:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: Yellow
```

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

- Compiler tells you **which** case is missing, by example.
- Fix: add a clause or a wildcard.

:::

The warning is friendly: it does not just say "this is
incomplete." It tells you *which value* breaks the match. For a
small variant, this is the missing constructor by name. For a
larger type, the compiler synthesises a sample value that no
clause covers, showing you the shape of the gap.

The fix is straightforward: add the missing clause.

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
```

Warning gone. The match now handles every possible
`traffic_light`. Crucially, the compiler has *proved* that this
function is total: it will never raise `Match_failure` at
runtime, no matter what value of `traffic_light` you pass it.

## How the check works

The exhaustiveness checker takes the type of the matched value
and computes the set of *value shapes* that type admits. For a
variant, that is the set of constructors (with their payload
patterns). For a tuple, the cross product of each component's
shapes. For a record, the set of all field combinations.

It then takes your clauses and subtracts the shapes they cover.
If the remainder is non-empty, the match is non-exhaustive, and
the compiler reports a witness from the remainder.

This is a *purely structural* check. It does not reason about
arithmetic, strings, or arbitrary computation. So on `int`, the
compiler treats every literal pattern as covering one specific
value and warns unless you have a wildcard or a variable pattern
that catches everything else. On `string`, the same: literals
cover only themselves; you need a catch-all.

```ocaml skip
let small = function
  | 0 -> "zero"
  | 1 -> "one"
  | 2 -> "two"
```

Warns: there are infinitely many integers, and you have covered
exactly three. The fix is `| _ -> "many"`, exactly as we did in
[Lecture 1](M05-L01-basic-patterns.html#the-catch-all-wildcard).

## Why this matters

In most mainstream languages, a "switch on a kind" can silently
fall through when you add a new kind:

:::slide

## Why this matters

- The compiler **proves** no `traffic_light` falls through at runtime.
- Without exhaustiveness checking, missing case becomes a runtime crash:
  - **C** (switch + enum): missing case falls through; depends on what's next.
  - **Java** (switch): same, unless a separate linter (Error Prone) is enabled.
  - **Python**: no static checking; runtime `KeyError`/`AttributeError`.
- OCaml flags the problem **before** the program runs.

:::

In C, a `switch` on an `enum` that misses a case compiles fine
and executes whatever code follows the missing case (or nothing,
if there is no `default`). In Java, the same; modern linters
like Error Prone can catch this, but it is not built into the
compiler. In Python, there is no static check at all; a missing
case becomes a runtime `KeyError`, `AttributeError`, or
silently wrong output.

OCaml builds the check into the compiler. It is the *default*
behaviour; you do not opt in, you opt out (if you must, with a
catch-all wildcard). This single feature shifts a whole class of
bugs (the "forgot a case" bug) from runtime to compile time.

## The big payoff: refactoring with the compiler

The reason exhaustiveness pays for itself many times over is
*refactoring*. Suppose you have a variant in a real codebase:

```ocaml skip
type traffic_light = Red | Yellow | Green
```

and twelve different functions that pattern-match on it. Now a
new requirement comes in: add a fourth state, `FlashingRed`.

```ocaml skip
type traffic_light = Red | Yellow | Green | FlashingRed
```

What happens? Every single `match` on `traffic_light` that did
not have a wildcard now emits warning 8. The compiler prints,
for each one, the location and the missing case. Your job is to
visit every flagged site and decide what to do for `FlashingRed`.

:::slide

## Refactor with the compiler

```ocaml skip
type traffic_light = Red | Yellow | Green | FlashingRed
```

- Every `match` on `traffic_light` warns about the new case.
- Compiler prints a punch-list: file + line for each match.
- Refactoring goes from "grep and pray" to "compile and fix the warnings".

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
  | FlashingRed -> "stop, then proceed with caution"
```

:::

This is what "refactor with the compiler" means. In a
dynamically-typed language, you have to *find* every site that
might need updating. You grep for `traffic_light`. You hope
nothing dynamic constructs the value (e.g., from a string).
You write more tests. You ship and find out at 2am that you
missed a branch.

In OCaml with variants and pattern matching, the compiler does
the finding for you. Adding a new constructor is mechanical:
introduce it in the type, then walk through the compiler's
punch list, fixing each warned site. When the warnings are gone,
you have changed every place that needed changing.

This is the property that *justifies* using variants for finite
kinds, even when a string or an integer would feel easier. With
strings (`light = "red"`, `light = "yellow"`), the compiler has no
idea what set of strings is valid; adding a new value to that
set is invisible to the type checker. With a variant, every
match is automatically a coverage check.

Once you internalise this, you will start to look at any code
that branches on a string and ask: *should this be a variant?*
The answer is almost always yes.

## The dual: redundant clauses

Exhaustiveness has a sibling check: **redundancy**. The
exhaustiveness check finds clauses that *should* exist but
don't. The redundancy check finds clauses that *do* exist but
will never fire.

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
  | Red -> "redundant"

let _ = action Red
```

:::slide

## Redundant clauses (warning 11)

```ocaml skip
let action = function
  | Red -> "stop"
  | Yellow -> "slow down"
  | Green -> "go"
  | Red -> "redundant"
```

```
Warning 11 [redundant-case]: this match case is unused.
```

- Second `Red` is **dead**.
- Same warning as the "variable-before-literal" case from Lecture 1.

:::

Warning 11 fires when a clause is *shadowed* by an earlier one.
The duplicate `Red` clause can never run, because the first
`Red` clause matches every red light. We saw the same warning
in [Lecture 1](M05-L01-basic-patterns.html#why-pattern-order-matters)
when a variable pattern appeared before a literal:

```ocaml skip
let label = function
  | n -> "got " ^ string_of_int n
  | 0 -> "zero"
```

Again, the variable `n` matches everything, so the literal `0`
is dead. Warning 11 tells you so, and the fix is to swap them.

The two warnings (8 for missing, 11 for redundant) together give
the compiler complete coverage of your match: every gap is
flagged, and every dead branch is flagged.

## Exhaustiveness on combined shapes

The checker handles nested patterns too. Take a pair of booleans:

```ocaml skip
let category = function
  | (true, true)  -> "both"
  | (true, false) -> "only first"
  | (false, true) -> "only second"

let _ = category (false, false)
```

:::slide

## Exhaustiveness on nested patterns

```ocaml skip
let category = function
  | (true, true)  -> "both"
  | (true, false) -> "only first"
  | (false, true) -> "only second"
```

```
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: (false, false)
```

- Compiler enumerates **all combinations** of nested shapes.
- Sees the gap and reports it.
- Fix: add `(false, false) -> "neither"`, or a wildcard.

:::

The compiler enumerated the 2x2 grid of boolean pairs, subtracted
the three covered combinations, and produced `(false, false)` as
the missing one. Same idea applies to a tuple of variants, a
record of variants, or a tree of constructors.

This is also how you can see that the check is *not* about types
alone but about *constructors*. The boolean type has two
constructors (`true`, `false`); a pair of booleans has four
constructor combinations; the check enumerates them.

The same principle applied to a tuple of two `traffic_light`s
would enumerate `3 * 3 = 9` combinations.

## Exhaustiveness and guards: one more reminder

We saw in [Lecture 3](M05-L03-guards.html#exhaustiveness-with-guards-is-conservative)
that guards suppress exhaustiveness. The
compiler treats a guarded clause as "may fail," so the cases
covered by a guarded pattern are not considered part of the
total. The fix is to add an unguarded catch-all:

```ocaml
let classify = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"
```

Without the wildcard, the compiler warns. Even though the two
guards logically partition the integers between them, the
compiler cannot prove that, and so it warns.

The lesson: when you write a guarded clause, *always* finish the
match with at least one unguarded clause, even if it seems
redundant to you.

## Why is it a warning, not an error?

You may have noticed that warning 8 is a *warning*, not an
*error*: the code still compiles and runs. This is a deliberate
choice in OCaml's defaults, and reasonable people disagree about
it.

The argument for a warning:

- During exploration and prototyping, the programmer often
  knows the input will be limited and a complete match is
  overkill.
- Sometimes the missing case is "impossible by invariant" and
  the programmer prefers a runtime `Match_failure` to
  cluttering the code with `assert false`.
- OCaml's defaults favour quick iteration; warnings let you
  proceed.

The argument against:

- A `Match_failure` at runtime is a worse user experience than a
  compile error.
- In production code, the cost of one missed case at runtime
  greatly exceeds the cost of writing the catch-all clause.
- The whole point of exhaustiveness is to shift the bug to
  compile time; tolerating it at compile time defeats the
  purpose.

In practice, every serious OCaml project I have worked on
treats warning 8 as an error. The default dune toolchain makes
this easy.

:::slide

## Treating warnings as errors

In real projects, treat partial-match warnings as errors:

```
(executable
 (name foo)
 (flags (:standard -w +a-3-49)))
```

- Or workspace-wide:
  ```
  (env (_ (flags (:standard -w +a-3-49))))
  ```
- `-w +a` makes all warnings into errors; `-3-49` disables a few benign ones.
- [Module 7](M07-L04-module-basics.html) covers modules; dune is the build tool you use to wire them together.

:::

The flag `(-w +a)` promotes every warning to an error. The
suffix `-3-49` disables warnings 3 and 49 (about deprecated
features and missing `cmi` files in some cases), which most
projects find acceptable to ignore. Warning 8 (exhaustiveness)
and warning 11 (redundancy) are *not* among the disabled ones,
so they become errors.

If you write OCaml seriously, set this in your dune files from
day one. The few minutes you spend appeasing the compiler in
each function will save you hours of debugging in production.

## When to use a wildcard catch-all on variants

A wildcard on a variant type *suppresses exhaustiveness* for
that match. If you write

```ocaml
type traffic_light = Red | Yellow | Green

let is_red = function
  | Red -> true
  | _ -> false
```

then later add a `FlashingRed` constructor, the wildcard
silently swallows it. `is_red FlashingRed` returns `false`,
which might be what you want or might be a serious bug. The
compiler will not tell you.

The discipline: avoid wildcards on variants unless you really
mean "everything else." For grouping cases that share a
right-hand side, prefer or-patterns:

```ocaml
type traffic_light = Red | Yellow | Green

let is_red = function
  | Red -> true
  | Yellow | Green -> false
```

Now if you add `FlashingRed`, the compiler warns and you make a
conscious choice about which side of the split it belongs on.

This is a strong rule worth internalising: *on variant types,
enumerate the cases explicitly*. Save the wildcard for `int`,
`string`, and other types where enumeration is impossible.

## Two checks

:::quiz mcq
Which of the following is the **strongest** reason to use a
variant type instead of a string when representing the set
`{"red", "yellow", "green"}`?

- [ ] Variants are faster.
- [ ] Variants use less memory.
- [x] The compiler can prove every `match` on the variant covers all cases, and warns when you add a new case.
- [ ] You cannot misspell a constructor.

**Why:** all four answers have a grain of truth (variants are
typically a little faster than strings, can be more compact, and
constructor names are checked by the compiler), but the
*strongest* argument is exhaustiveness. The compiler turns "did
I cover every case?" from a manual question into an automatic
check, and surfaces every place that needs updating when the
type grows.
:::

:::quiz mcq
After adding `FlashingRed` to the type below, what does the
compiler do for an existing function

```ocaml skip
let is_red = function | Red -> true | _ -> false
```

that uses a wildcard?

- [ ] Warns about non-exhaustiveness.
- [ ] Warns about a redundant case.
- [x] Stays silent; the wildcard catches `FlashingRed`.
- [ ] Refuses to compile.

**Why:** the wildcard `_` covers any constructor not listed
above, including new ones. The compiler treats the match as
already total and does not warn. This is why a wildcard on a
variant type silently disables one of the most useful refactoring
aids.
:::

A code task:

:::quiz code
Write `is_weekend : day -> bool` exhaustively, where:

```ocaml
type day = Mon | Tue | Wed | Thu | Fri | Sat | Sun
```

Return `true` for `Sat` and `Sun`, `false` for the rest. Use an
or-pattern to group, and **do not** use a wildcard.

```ocaml
type day = Mon | Tue | Wed | Thu | Fri | Sat | Sun

let is_weekend d =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (is_weekend Sat) "sat";
  check (is_weekend Sun) "sun";
  check (not (is_weekend Mon)) "mon";
  check (not (is_weekend Wed)) "wed";
  check (not (is_weekend Fri)) "fri";
  print_endline "all tests passed"
```
:::

The shape: `function | Sat | Sun -> true | Mon | Tue | Wed | Thu
| Fri -> false`. Listing all five weekday constructors explicitly
keeps the compiler in the loop: if anyone later adds `Holiday`
to the `day` type, every match on `day` (including this one) will
warn. With a wildcard `| _ -> false`, the warning would not
appear, and `Holiday` would silently be treated as a weekday.

## Common pitfalls

**Pitfall 1: silencing warnings with a wildcard.** A wildcard
defeats exhaustiveness. Use it on `int` and `string` where you
must; avoid it on variants.

**Pitfall 2: not enabling warnings-as-errors.** The default is
"warning only," which is fine for exploration. For production
code, promote to error in your dune flags. Make the compiler
your safety net.

**Pitfall 3: ignoring the witness.** The compiler tells you
*which* value the match misses. Read the witness. If it surprises
you, your mental model of the type is off, and the warning is
doing real work.

**Pitfall 4: assuming guards are checked.** They are not. Always
end a match that uses guards with an unguarded clause.

## Activity

:::slide

## Activity

Suppose you have a variant type `color = Red | Green | Blue`
that is matched in twelve places across a codebase. You want to
add a fourth case, `Yellow`. How does the OCaml compiler help,
and what does it *not* help with?

:::

Think about both halves before reading on.

:::slide

## Activity discussion

The compiler:

- Issues warning 8 at *every* match on `color` that misses `Yellow`.
- Tells you the missing case (`Yellow`) by example, with location.
- Does **not** tell you *what behaviour* `Yellow` should produce; that's a design decision.

Takeaways:

- Structural completeness: mechanically checked.
- Semantic correctness: up to you.
- The compiler answers "where?"; you answer "what?".
- Strongest practical reason to use **variants** for finite kinds.
- Strings can't give this guarantee.

:::

The compiler does the mechanical work for you: it finds every
site that pattern-matches on `color` and does not handle
`Yellow`, and it tells you both *where* (file and line) and
*what is missing* (the constructor name).

It does *not* know what `Yellow` should do at each site. That is
a design decision. Maybe `Yellow` should behave like `Red` in
some contexts and like `Green` in others. Maybe `Yellow` should
trigger an error. The compiler hands you the punch list; you
decide each item.

This division of labour is exactly the right one. The boring
part (finding all the sites) is mechanical; the compiler does
it. The interesting part (deciding what each site should do) is
yours. Without exhaustiveness, you would do both, badly.

## What's next

We have now covered the static analysis. [Lecture 5](M05-L05-records-variants.html)
returns to *syntax*: the everyday patterns for matching on records
and variants in real code, including the short forms for ignoring
fields, deeply nested matches, and the combination of patterns
that comes up in everyday OCaml.

:::slide

## What's next

- Lecture 5: **matching records and variants** in everyday code.
- Short forms (`{ field; _ }`), deeply nested matches, combinations.
- The patterns you reach for a hundred times a day.

:::

## Reading

- **Cornell CS3110**, *Exhaustiveness*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
- **Real World OCaml**, *Lists and patterns* (the
  pattern-matching efficiency and exhaustiveness sections):
  <https://dev.realworldocaml.org/lists-and-patterns.html>
