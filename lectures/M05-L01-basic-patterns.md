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
[Module 2](M02-L02-let-bindings.html), in small doses. From this
lecture on, pattern matching moves to the centre of the language. It
is, more than any single other feature, what makes OCaml *feel* like
OCaml. You will reach for it dozens of times a day: to take apart a
[tuple](M04-L01-tuples.html), to dispatch on a [constructor](M04-L03-variants.html),
to walk a [tree](M04-L04-recursive-types.html), to handle an
[option](M04-L05-option-and-aliases.html), to write the body of
nearly every interesting function.

The shape we start with is the `match` expression, the way you ask
"what shape is this value, and what should I do for each shape?"
In a curly-brace language you would reach for `switch`, or a
sequence of `if`/`else if`, or a dispatch table. OCaml's `match`
is the moral equivalent of all three, with one important upgrade:
the cases on the left can be *structured patterns*, not just
constants. The compiler will check that the patterns cover every
possibility, and warn when they do not. This lecture establishes
the basic shape and the three simplest pattern forms:

1. **Literal patterns** match a specific value (`0`, `'a'`, `"hello"`, `true`).
2. **Variable patterns** match *anything* and give the matched value a name.
3. **The wildcard** `_` matches anything and binds no name.

The next four lectures build on this base.
[Lecture 2](M05-L02-nested-and-or-patterns.html) covers patterns
inside patterns, and or-patterns. [Lecture 3](M05-L03-guards.html)
covers `when`-guards. [Lecture 4](M05-L04-exhaustiveness.html) is
about exhaustiveness, the most load-bearing static check in the
language. [Lecture 5](M05-L05-records-variants.html) puts it all
together for records and variants. [Lecture 6](M05-L06-tutorial.html)
is the tutorial.

## The shape of a `match`

Here is the smallest interesting example. Given an integer, we
want to label `0`, `1`, and `2` by name, and call everything else
"many":

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

- `match` takes a value (here `n`) and a list of clauses.
- Each clause: a **pattern** on the left, an **expression** on the right.
- **First pattern that matches wins**.
- Its right-hand side is the value of the whole `match`.

:::

Two important things to notice. First: a `match` is an
*expression*, not a statement. The whole thing has a value. That
value is the right-hand side of whichever clause matched. So you
can write `let label = match n with ...`, or pass a `match` as a
function argument, or use it as the body of another expression.
There is no separate "switch statement" in OCaml because there is
no statement/expression divide to begin with: everything is an
expression, and `match` is one of the most useful ones.

Second: the first pattern that matches wins. The clauses are tried
in order, top to bottom. As soon as one matches, its right-hand
side runs and the others are skipped. This is the same dispatch
rule as a chain of `if`/`else if`, and the same rule as a
fall-through-free C `switch`. We will return to this rule several
times in the lecture, because it interacts in interesting ways
with the variable pattern.

The leading `|` before the first clause is optional. Many
codebases include it for visual alignment with the rest. Some
omit it on the first line. Both are common; pick a style and be
consistent. Throughout this course we include the leading bar.

## Three kinds of pattern this week

The patterns you can write on the left of a clause form a small
language of their own. By the end of Module 5 we will have seen
most of it. For this first lecture we restrict ourselves to three
forms:

:::slide

## Three pattern forms this lecture

1. **Literal patterns**: `0`, `'a'`, `"hello"`, `true`. Match exactly
   that value.
2. **Variable patterns**: any name starting with a lowercase letter
   (`x`, `result`, `_data`). Matches *anything*; binds the matched
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
- Right-hand side uses `n` to refer to the matched value.

:::

A **literal pattern** is a value spelled exactly as it appears.
`0` matches the integer `0`. `'a'` matches the character `'a'`.
`"hello"` matches the string `"hello"`. `true` matches the boolean
`true`. The check is the same structural equality (`=`) we saw in
[M02-L04](M02-L04-operators.html#comparison-and-equality). Two
strings with the same bytes match; two records with the same fields
match. The literal pattern is the workhorse for "is this the special
case I want to handle?"

A **variable pattern** is a lowercase identifier. It matches
*anything at all*, and inside the right-hand side, that
identifier is bound to whatever the value was. So in the example
above, the pattern `n` matches `42` (because it matches
everything), and inside the body `string_of_int n` produces
`"42"`. A variable pattern is how you say "I want to handle the
remaining cases uniformly, and I need a name for the value."

The **wildcard** `_` is a special pattern that matches anything,
just like a variable pattern, but binds no name. The difference is
purely about whether you intend to use the value. Two reasons to
reach for `_`:

- You want a catch-all clause and do not need to refer to the
  matched value. `| _ -> "default"` is the standard way to write
  this.
- You want to destructure a value but ignore some piece of it.
  `| (x, _) -> x` extracts the first component of a pair without
  giving the second a name.

OCaml warns about unused variable bindings, so if you write
`(x, y) -> x` and never use `y`, the compiler will tell you. The
wildcard is the way to say "I am ignoring this on purpose; please
do not warn me."

## Why pattern order matters

Now for the trap that catches almost every student at least once.
Consider this version of `classify`:

```ocaml skip
let classify n =
  match n with
  | x -> "variable: " ^ string_of_int x
  | 0 -> "this never fires"

let _ = classify 0
```

What does `classify 0` return? Not `"this never fires"`. The
answer is `"variable: 0"`.

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
- The second clause is **unreachable**.
- OCaml warns:

```
Warning 11: this match case is unused.
```

- Rule: **specific patterns first, general patterns last.**

:::

The variable pattern `x` matches everything, including `0`. The
clauses are tried top to bottom; `x` succeeds on the very first
try; the right-hand side runs; the second clause is never
visited. OCaml's compiler will warn you about this:

```
Warning 11 [redundant-case]: this match case is unused.
```

Warning 11 is the dual of the exhaustiveness warning (warning 8,
which we will meet in [Lecture 4](M05-L04-exhaustiveness.html)): it
says you have a clause that *never* fires, usually because an
earlier clause already covers it. When you see warning 11, you have
almost certainly put a variable pattern (or a wildcard) before
something more specific, and that more specific clause is dead.

The discipline is simple: **specific patterns first, general
patterns last.** Put your literal cases before any variable or
wildcard catch-all. The example becomes:

```ocaml
let classify n =
  match n with
  | 0 -> "zero"
  | x -> "non-zero: " ^ string_of_int x

let _ = classify 0
let _ = classify 7
```

Now `classify 0` is `"zero"` and `classify 7` is `"non-zero: 7"`,
which is what we wanted.

This rule looks pedantic until you start writing pattern matches
on data types with several constructors. The compiler will not
guess what you meant; it will faithfully apply the order you wrote
and the warning is your only defence.

## `_` versus a variable name

There is a subtle but real difference between `_` and a fresh
variable name like `_unused`, even though both match anything.

The wildcard `_` *cannot be referenced on the right-hand side*; it
binds nothing. A variable name (even one starting with an
underscore, like `_x`) *is* a binding, and you can use it in the
body. The convention is: use `_` when you do not need the value;
use a name that starts with `_` when you want to *document* what
the ignored piece is, but you still do not intend to use it.

```ocaml
let first_only = function
  | (x, _) -> x

let _ = first_only (10, 20)
```

:::slide

## When to use `_` vs a variable

```ocaml
let first_only = function
  | (x, _) -> x

let _ = first_only (10, 20)
```

`int = 10`.

- Second component discarded; `_` makes that explicit.
- Writing `(x, y)` would trigger:

```
Warning 26: unused variable y.
```

- `_` says "I'm ignoring this on purpose"; the compiler respects it.

:::

`first_only (10, 20)` returns `10`. The wildcard in the second
position says "there is something here, I do not care what."
Writing `(x, y) -> x` would compile, but the compiler would warn
about the unused `y`:

```
Warning 26 [unused-var]: unused variable y.
```

Both warnings (11 and 26) are part of the same general philosophy:
the compiler does its best to flag patterns that look like they
were written by mistake. Most of the time the warning is right.

## The catch-all wildcard

The wildcard is also the standard way to write a default clause:

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

:::slide

## Catch-all wildcard

```ocaml
let direction_label = function
  | "n" -> "north"
  | "s" -> "south"
  | "e" -> "east"
  | "w" -> "west"
  | _ -> "unknown"
```

- Four specific cases for the strings we know about.
- Wildcard catches every other string.
- No name needed because we do not use the value.

:::

Four specific clauses, one catch-all. This is the everyday shape
for "I have a finite list of known inputs and want to fall back
on a default."

A small caution about catch-all wildcards on variant types:
they suppress exhaustiveness checking. If you have a variant
type with five constructors and you write four specific cases
plus a wildcard, and then later add a sixth constructor, the
compiler will *not* warn you, because the wildcard "covers" the
new case (probably with the wrong answer). We will return to
this in [Lecture 4](M05-L04-exhaustiveness.html#when-to-use-a-wildcard-catch-all-on-variants).
For now, use the wildcard freely on `int`s and `string`s, where
there is no other way to enumerate the cases; use it more
cautiously on variants.

## `function` shorthand

When a one-argument function's *whole body* is a `match` on the
argument, OCaml lets you skip the boilerplate. Instead of:

```ocaml
let classify n =
  match n with
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "many"
```

you can write:

```ocaml
let classify = function
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "many"
```

:::slide

## `function` shorthand

When a one-arg function's whole body is a `match` on the argument:

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
- Works only for *one-argument* functions.

:::

The `function` keyword stands for "take one argument and
immediately `match` on it." It is shorter and reads more cleanly
when the function is essentially a multi-way dispatch on its
input. Idiomatic OCaml uses `function` very often. We will use it
throughout the rest of this module.

The one limitation: `function` only matches on a *single*
argument, the function's input. For a two-argument function, you
have two options: a regular `match` on a tuple of the two
arguments, or a `let` of a `match` in the body. The `function`
shorthand cannot do this directly. For one-argument functions,
prefer `function`.

## Patterns appear everywhere, not just in `match`

The patterns you use in `match` are not a `match`-specific
feature. They are a general feature of OCaml that surfaces in
several places.

```ocaml
let (x, y) = (3, 4)
let _ = x + y
```

The left-hand side of a `let` is also a pattern. So you can
destructure a tuple in a `let` binding directly: `(x, y) = (3, 4)`
binds `x = 3` and `y = 4`. We have been using this since
[Module 4](M04-L01-tuples.html#pattern-matching-in-function-arguments)
without calling it pattern matching, but that is exactly what it is.

:::slide

## Patterns are everywhere

`let` takes a pattern on the left:

```ocaml
let (x, y) = (3, 4)
let _ = x + y
```

- `x` and `y` are bound by **destructuring** the pair.

Function parameters can also be patterns:

```ocaml
let sum (a, b) = a + b

let _ = sum (3, 4)
```

`int = 7`. The parameter pattern destructures the pair on the way in.

:::

Function parameters are also patterns. `let sum (a, b) = a + b`
defines a function whose single parameter is a pair, and the
pattern `(a, b)` immediately splits the pair into its components.
You could equivalently write:

```ocaml
let sum p =
  let (a, b) = p in
  a + b
```

Both desugar to roughly the same code. The pattern-in-parameter
form is shorter; use it when the function expects a structured
argument and you want the pieces named right away.

One important constraint on these "patterns elsewhere": unlike
`match`, where you have many clauses and the compiler picks one,
a `let` pattern or function-parameter pattern has *only one*
shape, and the value had better match it. If it does not, the
program raises `Match_failure` at runtime. So `let (x, y) = z`
works only if `z` is a pair; `let Some n = opt` works only if
`opt` is `Some _`. The compiler will warn you about partial
matches like this; we will see the warning in
[Lecture 4](M05-L04-exhaustiveness.html).

## A quick taste of exhaustiveness

Even at this early stage, the compiler is watching for missing
cases. Here is a non-exhaustive match:

```ocaml skip
let label = function
  | 0 -> "zero"
  | 1 -> "one"
```

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

- The compiler shows a sample input no clause covers.
- Fix: add more clauses, or add a wildcard `_`.
- Full coverage in Lecture 4.

:::

OCaml emits warning 8 and reports a sample missing input. The
fix is either to add more specific clauses (`| 2 -> "two"`, etc.)
or to add a wildcard catch-all (`| _ -> "many"`). On finite types
like booleans or small variants, you can usually enumerate every
case; on `int`, you almost always end with a wildcard.
[Lecture 4](M05-L04-exhaustiveness.html) covers exhaustiveness in
detail; for now, just know that the warning exists and is helpful.

## How `match` evaluates

The mental model for `match v with | p1 -> e1 | p2 -> e2 | ...`
is:

1. Evaluate `v` to a value.
2. Try to match that value against `p1`.
3. If `p1` matches: bind any variables that `p1` introduces, then
   evaluate `e1`. That is the answer.
4. If `p1` does not match: try `p2`. And so on.
5. If no pattern matches: raise `Match_failure` at runtime.

The "match" check itself is structural. A literal pattern `0`
matches the value `0`. A variable pattern always matches and
records the binding. A wildcard always matches and records
nothing. Patterns we will see in later lectures (tuples,
constructors, lists) match piece by piece.

Crucially, the *value* `v` is evaluated exactly once. The
patterns do not re-trigger any side effect in `v`. So this is
safe:

```ocaml
let _ =
  match Random.int 10 with
  | 0 -> "rolled zero"
  | _ -> "rolled non-zero"
```

The `Random.int 10` call happens once; the resulting number is
the thing the patterns inspect.

## Putting it to work: a small check

A common idiom: convert a "kind" represented as a string into a
typed value, with a default for unknown inputs.

```ocaml
let parse_level = function
  | "debug" -> 0
  | "info"  -> 1
  | "warn"  -> 2
  | "error" -> 3
  | _       -> 1   (* default to info *)

let _ = parse_level "warn"
let _ = parse_level "verbose"
```

`int = 2` and `int = 1`. The four literal patterns handle the
recognised levels; the wildcard handles everything else. The
shape is repetitive enough that it is tempting to reach for a
hash table or an `assoc` list, but at five entries the pattern
match is shorter, clearer, and faster than any data structure.

## Two checks

:::quiz mcq id=M05-L01-q3
What does this evaluate to?

```ocaml
let f = function
  | 0 -> "zero"
  | _ -> "other"

let result = f 0
```

- [x] `"zero"`
- [ ] `"other"`
- [ ] Warning 11 (unused case)
- [ ] Compile error
:::

:::quiz mcq id=M05-L01-q2
What does this evaluate to?

```ocaml skip
let f = function
  | n -> "got " ^ string_of_int n
  | 0 -> "zero"

let result = f 0
```

- [x] `"got 0"` (with a compiler warning)
- [ ] `"zero"`
- [ ] Compile error
- [ ] `Match_failure` at runtime

**Why:** the first clause `n` is a variable pattern. It matches
*anything*, including `0`, and binds `n` to the matched value. So
`f 0` runs the first clause and produces `"got 0"`. The second
clause `0 -> "zero"` is unreachable. OCaml emits warning 11
("this match case is unused"), but the code still compiles and
runs.
:::

A code task:

:::quiz code id=M05-L01-q1
Write `traffic_action : string -> string` that returns:

- `"stop"` when the input is `"red"`,
- `"slow"` when the input is `"yellow"`,
- `"go"` when the input is `"green"`,
- `"unknown signal"` for anything else.

Use a `function` shorthand with literal patterns and a wildcard.

```ocaml
let traffic_action = function
  | _ -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (traffic_action "red"    = "stop") "red";
  check (traffic_action "yellow" = "slow") "yellow";
  check (traffic_action "green"  = "go") "green";
  check (traffic_action "purple" = "unknown signal") "default";
  print_endline "all tests passed"
```
:::

The shape: four literal patterns followed by a wildcard. This is
the same skeleton as `direction_label` earlier; what changes is
just the strings.

## Common pitfalls

A short list of mistakes that show up every cohort.

**Pitfall 1: variable-first, specific-second.** As we saw,
putting `| x -> ...` before `| 0 -> ...` makes the second clause
dead. The compiler warns; read the warning. The order is
specific-first, general-last.

**Pitfall 2: forgetting the leading `|` is optional.** The very
first clause does not need a leading bar; subsequent clauses do.
Mixing the two styles in one match is fine; pick one and be
consistent. Most of the OCaml ecosystem uses a leading bar on
every clause, including the first, for vertical alignment.

**Pitfall 3: `match` is an expression.** All clauses must produce
values of the *same type*. If one clause returns `"hello"` and
another returns `42`, the compiler will reject the whole `match`.
This is the same expression-typing rule we saw for `if`/`else` in
[M02-L05](M02-L05-if-expressions.html#why-the-branches-must-agree).

**Pitfall 4: forgetting the wildcard on `int` or `string`.** OCaml
will let you write a `match` on `int` with only specific cases
(`0 -> ...`, `1 -> ...`), and will warn that you have not covered
`2`, `3`, and so on. Add a wildcard. The compiler is right; the
match is incomplete.

## Activity

:::slide

## Activity

Why does the following always return `0`, regardless of clause
order?

```ocaml skip
let f = function
  | x -> x
  | 0 -> 99

let _ = f 0
let _ = f 5
```

:::

Predict before reading on.

:::slide

## Activity discussion

- Variable pattern `x` matches *any* integer, including `0`.
- `x` appears first, so it wins.
- Second clause is unreachable; warning 11.
- `f 0` returns `0`; `f 5` returns `5`.

The fix:

```ocaml skip
let f = function
  | 0 -> 99
  | x -> x
```

- Now `f 0` returns `99`; `f n` returns `n` for any other `n`.

:::

The variable pattern `x` matches everything. The clause that says
"return `99` when the input is `0`" never runs because `x` already
matched the input before `0` got a chance. Putting the specific
case first restores the intended behaviour.

This is the cleanest illustration of why pattern order matters,
and why "specific first, general last" is the rule to internalise.

## What's next

[Lecture 2](M05-L02-nested-and-or-patterns.html) covers two
extensions to the patterns we have seen: patterns inside patterns
(nesting), and or-patterns (`p1 | p2`) that let multiple alternatives
share a right-hand side. Both let you express more in a single
clause. [Lecture 3](M05-L03-guards.html) adds `when` guards.
[Lecture 4](M05-L04-exhaustiveness.html) puts exhaustiveness on a
firmer footing. By the end of Module 5 you will be writing pattern
matches as easily as you write arithmetic.

:::slide

## What's next

- Lecture 2: **nested patterns and or-patterns**.
- Patterns can contain other patterns: `Some (x, _)`, `(0, _) :: _`.
- `|` inside a clause lets multiple shapes share a right-hand side.

:::

## Reading

- **Cornell CS3110**, *Pattern matching*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
- **Real World OCaml**, *Lists and patterns* (the pattern-matching
  sections):
  <https://dev.realworldocaml.org/lists-and-patterns.html>
